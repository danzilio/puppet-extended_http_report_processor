require 'puppet'
require 'puppet/network/http_pool'
require 'uri'

Puppet::Reports.register_report(:extended_http) do
  def content_type(format)
    case format
    when 'yaml'
      'application/x-yaml'
    when 'json'
      'application/json'
    else
      raise Puppet.err("The extended HTTP report processor only supports json and yaml but you requested #{format}")
    end
  end

  def config(path = "#{Puppet[:confdir]}/extended_http.yaml")
    raw_config = YAML.load_file(path)
    processed_config = {}
    raw_config['endpoints'].each do |endpoint,conf|
      conf = conf.nil? ? {} : conf
      url = URI.parse(endpoint)
      format = conf['format'] || 'yaml'
      raw_headers = conf['headers'] || {}

      processed_config[url] = {
        headers: raw_headers.merge({'Content-Type' => content_type(format)}),
        options: {metric_id: [:puppet, :report, :http]},
        type: format,
      }

      if conf['username'] && conf['password']
        processed_config[url][:options][:basic_auth] = {
          user: conf['username'],
          password: conf['password']
        }
      end
    end

    return processed_config
  end

  def process
    config.each do |endpoint, conf|
      use_ssl = endpoint.scheme == 'https'
      conn = Puppet::Network::HttpPool.http_instance(endpoint.host, endpoint.port, use_ssl)
      response = conn.post(endpoint.path, self.send("to_#{conf[:type]}"), conf[:headers], conf[:options])
      unless response.kind_of?(Net::HTTPSuccess)
        Puppet.err _("Unable to submit report to %{url} [%{code}] %{message}") % { url: endpoint.to_s, code: response.code, message: response.msg }
      end
    end
  end
end