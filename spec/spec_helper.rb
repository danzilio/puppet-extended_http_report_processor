require 'rspec-puppet'
require 'puppetlabs_spec_helper/puppet_spec_helper'
require 'puppetlabs_spec_helper/module_spec_helper'

def fixture_path
  File.expand_path(File.join(__FILE__, '..', 'fixtures'))
end

def confdir
  File.expand_path(File.join(fixture_path, 'etc/puppetlabs/puppet'))
end

def write_config(config)
  FileUtils.mkdir_p(confdir) unless File.directory?(confdir)
  File.open(File.join(confdir, 'extended_http.yaml'), 'w+') do |f|
    f.write({ 'endpoints' => config }.to_yaml)
  end
end

RSpec.configure do |c|
  c.formatter = 'documentation'

  c.before :each do
    Puppet[:confdir] = confdir
  end
end