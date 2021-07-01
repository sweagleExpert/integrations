# The `sweagle_lookup_key` is a hiera 5 `lookup_key` data provider function.
# See [the configuration guide documentation](https://puppet.com/docs/puppet/latest/hiera_config_yaml_5.html#configuring-a-hierarchy-level-hiera-eyaml) for
# how to use this function.
#
# @since 5.0.0
#
Puppet::Functions.create_function(:sweagle_lookup_key) do
  unless Puppet.features.hiera_eyaml?
    raise Puppet::DataBinding::LookupError, 'Lookup using eyaml lookup_key function is only supported when the hiera_eyaml library is present'
  end

  require 'hiera/backend/eyaml/encryptor'
  require 'hiera/backend/eyaml/utils'
  require 'hiera/backend/eyaml/options'
  require 'hiera/backend/eyaml/parser/parser'

  dispatch :sweagle_lookup_key do
    param 'String[1]', :key
    param 'Hash[String[1],Any]', :options
    param 'Puppet::LookupContext', :context
  end

  def sweagle_lookup_key(key, options, context)
    # Return the value from cache if key is already there
    return context.cached_value(key) if context.cache_has_key(key)

    # Can't do this with an argument_mismatch dispatcher since there is no way to declare a struct that at least
    # contains some keys but may contain other arbitrary keys.
    #unless options.include?('key')
    #  raise ArgumentError,
    #    _("'sweagle_lookup_key': 'key' must be declared in hiera.yaml when using this lookup_key function")
    #end

    require 'net/http'
    require 'net/https'
    require 'uri'

    # Manage input options with default values
    if (defined?(options['sweagle_cds']) and options['sweagle_cds'] != nil)
      then sweagle_cds = options['sweagle_cds']
      else sweagle_cds = "hiera" end
    if (defined?(options['keypath']) and options['keypath'] != nil) then
      sweagle_args = options['keypath'] + '/' + key
      sweagle_parser = "returnValueForKeyInPath"
    elsif (defined?(options['keynode']) and options['keynode'] != nil) then
      sweagle_args = options['keynode'] + ',' + key
      sweagle_parser = "returnValueForKeyAtNode"
    else
      sweagle_args = key
      sweagle_parser = "returnValueForKey"
    end
    if (defined?(options['sweagle_parser']) and options['sweagle_parser'] != nil)
      then sweagle_parser = options['sweagle_parser'] end
    if (defined?(options['sweagle_tenant']) and options['sweagle_tenant'] != nil)
      then sweagle_tenant = options['sweagle_tenant']
    else sweagle_tenant = "https://testing.sweagle.com" end
    if (defined?(options['sweagle_token']) and options['sweagle_token'] != nil)
      then sweagle_token = options['sweagle_token']
      else sweagle_token = "<YOUR_TOKEN>" end
    if (defined?(options['proxy_uri']) and options['proxy_uri'] != nil)
      then proxy_uri = options['proxy_uri']
      else proxy_uri = "" end
    if (defined?(options['sweagle_tag']) and options['sweagle_tag'] != nil)
      then sweagle_tag = options['sweagle_tag']
      else sweagle_tag = "" end

    uri = URI.parse(sweagle_tenant)
    proxy = URI.parse(proxy_uri)
    @http = Net::HTTP.new(uri.host, uri.port, proxy.host, proxy.port)
    @http.use_ssl = true
    #@http.set_debug_output($stdout)
    Puppet.debug("[sweagle_lookup_key]: Lookup key =(#{key})")
    Puppet.info("[sweagle_lookup_key]: cds (#{sweagle_cds}) with exporter (#{sweagle_parser}) and arg (#{sweagle_args}) from SWEAGLE tenant "+sweagle_tenant)
    httpreq = Net::HTTP::Post.new('/api/v1/tenant/metadata-parser/parse?mds='+sweagle_cds+'&parser='+sweagle_parser+'&format=json&arraySupport=true&args='+sweagle_args+'&tag='+sweagle_tag)
    header = {
      'Authorization' => 'Bearer ' + sweagle_token,
      "Accept" => 'application/json',
      'Content-Type' => 'application/json'
    }
    httpreq.initialize_http_header(header)

    begin
      httpres = @http.request(httpreq)
    rescue Exception => e
      Puppet.warning("[sweagle_lookup_key]: Net::HTTP threw exception #{e.message}")
      raise Exception, e.message unless @config[:failure] == 'graceful'
    end

    unless httpres.kind_of?(Net::HTTPSuccess)
      Puppet.debug("[sweagle_lookup_key]: bad http response from SWEAGLE tenant")
      Puppet.debug("HTTP response code was #{httpres.code}")
      unless ( httpres.code == '404' && @config[:ignore_404] == true )
        raise Exception, 'Bad HTTP response' unless @config[:failure] == 'graceful'
      end
    end

    content = httpres.body
    Puppet.debug("[sweagle_lookup_key]: SWEAGLE HTTP response = #{content}")
    if content.include? "ERROR:"
      Puppet.info("[sweagle_lookup_key]: Error received from SWEAGLE exporter, key not found")
      context.not_found
    else
      Puppet.info("[sweagle_lookup_key]: Key value found, parse Json result")
      #content = '{"' + key + '": ' + httpres.body + '}'
      #Puppet.warning("[sweagle_lookup_key]: content = #{content}")
      #Puppet::Pops::Lookup::HieraConfig.symkeys_to_string(content)
      begin
        content = Puppet::Util::Json.load(content)
      rescue Puppet::Util::Json::ParseError => ex
        raise Puppet::DataBinding::LookupError, "Unable to parse SWEAGLE response: %{message}" % { message: ex.message }
      end
      #context.cache(key, content)
      context.cache(key, decrypt_value(content, context, options, key))
    end

  end

  def decrypt_value(value, context, options, key)
    case value
    when String
      decrypt(value, context, options, key)
    when Hash
      result = {}
      value.each_pair { |k, v| result[context.interpolate(k)] = decrypt_value(v, context, options, key) }
      result
    when Array
      value.map { |v| decrypt_value(v, context, options, key) }
    else
      value
    end
  end

  def decrypt(data, context, options, key)
    if encrypted?(data)
      # Options must be set prior to each call to #parse since they end up as static variables in
      # the Options class. They cannot be set once before #decrypt_value is called, since each #decrypt
      # might cause a new lookup through interpolation. That lookup in turn, might use a different eyaml
      # config.
      #
      Hiera::Backend::Eyaml::Options.set(options)
      begin
        tokens = Hiera::Backend::Eyaml::Parser::ParserFactory.hiera_backend_parser.parse(data)
        data = tokens.map(&:to_plain_text).join.chomp
      rescue StandardError => ex
        raise Puppet::DataBinding::LookupError,
          _("hiera-eyaml backend error decrypting %{data} when looking up %{key}. Error was %{message}") % { data: data, key: key, message: ex.message }
      end
    end
    context.interpolate(data)
  end

  def encrypted?(data)
    /.*ENC\[.*?\]/ =~ data ? true : false
  end
end
