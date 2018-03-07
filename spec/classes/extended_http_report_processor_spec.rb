require 'spec_helper'

describe 'extended_http_report_processor' do
  context 'with valid parameters' do
    context 'with a hash of endpoints' do
      let(:params) do {
        endpoints: {
          'http://example.com': { format: 'yaml' }
        }}
      end

      it { is_expected.to compile }
      it { is_expected.to contain_file('extended_http_report_processor_config').with_content(/endpoints:\s+http:\/\/example.com:\s+format:\s+yaml/) }
    end

    context 'with an array of endpoints' do
      let(:params) do {
        endpoints: [
          'http://example.com/report',
          'http://example.com/upload'
        ]}
      end

      it { is_expected.to compile }
      it { is_expected.to contain_file('extended_http_report_processor_config').with_content(/endpoints:\s+- http:\/\/example.com\/report\s+- http:\/\/example.com\/upload/) }
    end

    context 'with enable set to true' do
      let(:params) do {
        enable: true,
        endpoints: [
          'http://example.com/report',
          'http://example.com/upload'
        ]}
      end

      it { is_expected.to compile }
      it { is_expected.to contain_file('extended_http_report_processor_config') }
      it { is_expected.to contain_ini_subsetting('puppet.conf/reports/extended_http').that_requires('File[extended_http_report_processor_config]') }
      it { is_expected.to contain_ini_setting('puppet.conf/report/true').that_requires('Ini_subsetting[puppet.conf/reports/extended_http]') }
    end

    context 'with enable set to false' do
      let(:params) do {
        enable: false,
        endpoints: [
          'http://example.com/report',
          'http://example.com/upload'
        ]}
      end

      it { is_expected.to compile }
      it { is_expected.to contain_file('extended_http_report_processor_config') }
      it { is_expected.not_to contain_ini_subsetting('puppet.conf/reports/extended_http') }
      it { is_expected.not_to contain_ini_setting('puppet.conf/report/true') }
    end
  end

  context 'with invalid parameters' do
    context 'with a string endpoint' do
      let(:params) {{ endpoints: 'foo' }}

      it { is_expected.to raise_error Puppet::Error }
    end

    context 'with a bad value for format' do
      let(:params) do {
        endpoints: {
          'http://example.com': { format: 'hocon' }
        }}
      end

      it { is_expected.to raise_error Puppet::Error }
    end

    context 'with a bad value for headers' do
      let(:params) do {
        endpoints: {
          'http://example.com': { headers: 'foo' }
        }}
      end

      it { is_expected.to raise_error Puppet::Error }
    end

    context 'with a bad value for username and password' do
      let(:params) do {
        endpoints: {
          'http://example.com': { username: ['foo'], password: ['bar'] }
        }}
      end

      it { is_expected.to raise_error Puppet::Error }
    end
  end
end

