# This is the extended_http_report_processor class
#
# @summary This class configures the extended_http report processor in 
#          `puppet.conf` and allows you to configure endpoints in
#          `extended_http.yaml`.
#
# @example Declaring the class
#     class { 'extended_http_report_processor':
#       endpoints => {
#         'http://endpoint1.example.com/upload' => {
#           'format'   => 'json',
#           'username' => 'foo',
#           'password' => 'bar',
#         },
#         'https://endpoint2.example.com:8080/reports' => {
#           'format'  => 'yaml',
#           'headers' => { 'Authorization' => 'f29cf5da-bb8a-428a-85e2-543d7524640c' },
#         },
#       }
#     }
#
# @param endpoints     This is a required parameter. It can be either an Array[String] or a
#                      Hash of endpoints. The endpoint type is documented in `types/endpoint.pp`
# @param puppet_config This is an optional parameter. It allows you to specify the location
#                      of your `puppet.conf` file. The default is `$settings::config`.
# @param enable        This is an optional parameter. This toggeles whether this module manages
#                      the `report` and `reports` settings in `puppet.conf`. The default is true.
class extended_http_report_processor (
  Extended_http_report_processor::Endpoints $endpoints,
  Stdlib::Absolutepath                      $puppet_config = $settings::config,
  Boolean                                   $enable        = true,
) {

  $config = "${settings::confdir}/extended_http.yaml"

  file { 'extended_http_report_processor_config':
    ensure  => present,
    path    => $config,
    content => inline_template('<%= { "endpoints" => @endpoints }.to_yaml %>'),
  }

  if $enable {
    ini_subsetting { 'puppet.conf/reports/extended_http':
      ensure               => present,
      path                 => $puppet_config,
      section              => 'master',
      setting              => 'reports',
      subsetting           => 'extended_http',
      subsetting_separator => ',',
      require              => File[$config]
    }

    ini_setting { 'puppet.conf/report/true':
      ensure  => present,
      path    => $puppet_config,
      section => 'master',
      setting => 'report',
      value   => 'true', # lint:ignore:quoted_booleans
      require => Ini_subsetting['puppet.conf/reports/extended_http']
    }
  }
}
