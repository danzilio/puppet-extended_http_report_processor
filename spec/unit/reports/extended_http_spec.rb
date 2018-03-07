require 'spec_helper'
require 'puppet/reports'

processor = Puppet::Reports.report(:extended_http)

describe processor do
  subject { Puppet::Transaction::Report.new.extend(processor) }
  let(:connection) { stub_everything 'connection' }
  let(:httpok) { Net::HTTPOK.new('1.1', 200, '') }
  let(:options) { {:metric_id => [:puppet, :report, :http]} }

  context 'with a single endpoint' do
    let(:config) {{
      'http://localhost/upload' => {}
    }}

    before :each do
      Puppet::Network::HttpPool.expects(:http_instance).returns(connection)
    end

    it 'properly posts yaml' do
      write_config(config)

      connection.expects(:post).with('/upload', subject.to_yaml, has_entry("Content-Type" => "application/x-yaml"), options).returns(httpok)
      subject.process
    end

    it 'properly posts json' do
      config['http://localhost/upload']['format'] = 'json'
      write_config(config)

      connection.expects(:post).with('/upload', subject.to_json, has_entry("Content-Type" => "application/json") , options).returns(httpok)
      subject.process
    end

    it 'injects the proper headers' do
      config['http://localhost/upload']['headers'] = { 'Authorization' => 'foobar' }
      write_config(config)
  
      connection.expects(:post).with('/upload', anything, has_entries("Content-Type" => 'application/x-yaml', "Authorization" => "foobar"), options).returns(httpok)
      subject.process
    end

    it 'properly encodes the authentication credentials' do
      config['http://localhost/upload']['username'] = 'foo'
      config['http://localhost/upload']['password'] = 'bar'

      basic_auth = { basic_auth: {user: 'foo', password: 'bar'}}
      write_config(config)
  
      connection.expects(:post).with('/upload', anything, anything, has_entries(basic_auth)).returns(httpok)
      subject.process
    end
  end

  context 'with multiple endpoints' do
    context 'without specifying any config by passing an array' do
      let(:config) {[
        'http://localhost/upload',
        'http://localhost/reports'
      ]}

      it 'posts to both endpoints' do
        write_config(config)
        Puppet::Network::HttpPool.expects(:http_instance).at_least(2).returns(connection)
        connection.expects(:post).with('/upload', anything, has_entry("Content-Type" => "application/x-yaml"), options).returns(httpok)
        connection.expects(:post).with('/reports', anything, has_entry("Content-Type" => "application/x-yaml"), options).returns(httpok)
        subject.process
      end
    end

    context 'without specifying any config by passing a hash' do
      let(:config) {{
        'http://localhost/upload' => {},
        'http://localhost/reports' => {}
      }}

      it 'posts to both endpoints' do
        write_config(config)
        Puppet::Network::HttpPool.expects(:http_instance).at_least(2).returns(connection)
        connection.expects(:post).with('/upload', anything, has_entry("Content-Type" => "application/x-yaml"), options).returns(httpok)
        connection.expects(:post).with('/reports', anything, has_entry("Content-Type" => "application/x-yaml"), options).returns(httpok)
        subject.process
      end
    end

    context 'when specifying a config' do
      let(:config) {{
        'http://localhost/upload' => {
          'format' => 'json'
        },
        'http://localhost/reports' => {
          'format' => 'yaml'
        }
      }}

      it 'posts to both endpoints' do
        write_config(config)
        Puppet::Network::HttpPool.expects(:http_instance).at_least(2).returns(connection)
        connection.expects(:post).with('/upload', anything, has_entry("Content-Type" => "application/json"), options).returns(httpok)
        connection.expects(:post).with('/reports', anything, has_entry("Content-Type" => "application/x-yaml"), options).returns(httpok)
        subject.process
      end
    end
  end
end