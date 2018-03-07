class extended_http_report_processor (
  Extended_http_report_processor::Endpoints $endpoints,
  Stdlib::Absolutepath                      $config        = "${settings['confdir']}/extended_http.yaml",
  Stdlib::Absolutepath                      $puppet_config = $settings['config'],
  Boolean                                   $enable        = true,
) {

  file { $config:
    ensure  => present,
    content => 'inline_template(<%= { "endpoints" => @endpoints }.to_yaml %>)',
  }

  if $enable {
    ini_subsetting { 'puppet.conf/reports/extended_http':
      ensure               => present,
      path                 => $puppet_config,
      section              => 'main',
      setting              => 'reports',
      subsetting           => 'extended_http',
      subsetting_separator => ','
      require              => File[$config]
    }

    ini_setting { 'puppet.conf/report/true':
      ensure  => present,
      path    => $puppet_config,
      section => 'main',
      setting => 'report',
      value   => 'true',
      require => Ini_subsetting['puppet.conf/reports/extended_http']
    }
  }
}
