Puppet::Functions.create_function(:sweagle_data_hash) do
  dispatch :sweagle_data_hash do
    param 'Struct[{path=>String[1]}]', :options
    param 'Puppet::LookupContext', :context
  end

  argument_mismatch :missing_path do
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def sweagle_data_hash(options, context)
    require 'net/http'
    require 'net/https'
    require 'uri'

    sweagle_tenant = "https://testing.sweagle.com"
    sweagle_token = "<YOUR_TOKEN>"

    uri = URI.parse(sweagle_tenant)
    @http = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = true
    #@http.set_debug_output($stdout)

    path = options['path']
    Puppet.debug("[sweagle_data_hash]: Lookup #{path} from SWEAGLE tenant")
    httpreq = Net::HTTP::Post.new('/api/v1/tenant/metadata-parser/parse?mds=hiera&parser=returnDataForNode&format=json&args=sample-test')
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
      raise Puppet::DataBinding::LookupError, "Unable to parse (%{path}): %{message}" % { path: path, message: ex.message }
    end
  end

  def missing_path(options, context)
    "one of 'path', 'paths' 'glob', 'globs' or 'mapped_paths' must be declared in hiera.yaml when using this data_hash function"
  end
end
