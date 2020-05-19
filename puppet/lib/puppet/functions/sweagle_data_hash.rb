Puppet::Functions.create_function(:sweagle_data_hash) do
  dispatch :sweagle_data_hash do
    #param 'Struct[{path=>String[1]}]', :options
    param 'Hash[String[1],Any]', :options
    param 'Puppet::LookupContext', :context
  end

  #argument_mismatch :missing_arg do
    #param 'Hash', :options
  #  param 'Puppet::LookupContext', :context
  #end

  def sweagle_data_hash(options, context)
    require 'net/http'
    require 'net/https'
    require 'uri'

    # Manage input options with default values
    if (defined?(options['sweagle_cds']) and options['sweagle_cds'] != nil)
      then sweagle_cds = options['sweagle_cds']
      else sweagle_cds = "hiera" end
    if (defined?(options['sweagle_args']) and options['sweagle_args'] != nil)
      then sweagle_args = options['sweagle_args']
      else sweagle_args = sweagle_cds end
    if (defined?(options['sweagle_parser']) and options['sweagle_parser'] != nil)
      then sweagle_parser = options['sweagle_parser']
      else sweagle_parser = "returnDataForNode" end
    if (defined?(options['sweagle_tenant']) and options['sweagle_tenant'] != nil)
      then sweagle_tenant = options['sweagle_tenant']
      else sweagle_tenant = "https://testing.sweagle.com" end
    if (defined?(options['sweagle_token']) and options['sweagle_token'] != nil)
      then sweagle_token = options['sweagle_token']
      else sweagle_token = "<YOUR_TOKEN>" end

    uri = URI.parse(sweagle_tenant)
    @http = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = true
    #@http.set_debug_output($stdout)

    Puppet.info("[sweagle_data_hash]: Lookup cds (#{sweagle_cds}) with exporter (#{sweagle_parser}) and args (#{sweagle_args}) from SWEAGLE tenant "+sweagle_tenant)
    httpreq = Net::HTTP::Post.new('/api/v1/tenant/metadata-parser/parse?mds='+sweagle_cds+'&parser='+sweagle_parser+'&format=json&args='+sweagle_args)
    header = {
      'Authorization' => 'Bearer ' + sweagle_token,
      "Accept" => 'application/json',
      'Content-Type' => 'application/json'
    }
    httpreq.initialize_http_header(header)

    begin
      httpres = @http.request(httpreq)
    rescue Exception => e
      Puppet.warning("[sweagle_data_hash]: Net::HTTP threw exception #{e.message}")
      raise Exception, e.message unless @config[:failure] == 'graceful'
    end

    unless httpres.kind_of?(Net::HTTPSuccess)
      Puppet.debug("[sweagle_data_hash]: bad http response from SWEAGLE tenant")
      Puppet.debug("HTTP response code was #{httpres.code}")
      unless ( httpres.code == '404' && @config[:ignore_404] == true )
        raise Exception, 'Bad HTTP response' unless @config[:failure] == 'graceful'
      end
    end

    content = httpres.body
    Puppet.debug("[sweagle_data_hash]: SWEAGLE HTTP response content= #{content}")
    begin
      Puppet::Util::Json.load(content)
    rescue Puppet::Util::Json::ParseError => ex
      # Filename not included in message, so we add it here.
      raise Puppet::DataBinding::LookupError, "Unable to parse SWEAGLE response: %{message}" % { message: ex.message }
    end
  end

  def missing_arg(options, context)
    "one of 'arg (<put here list of authorised args>) must be declared in hiera.yaml when using this data_hash function"
  end
end
