# An extended HTTP report processor for Puppet

This module provides a report processor for Puppet with more configurability than the built in http report processor. My initial use case was to be able to add headers to the request when submitting reports. This report processor also supports multiple HTTP endpoints whereas the built in processor only supports one.

The module also includes a simple Puppet class to configure the report processor.

## Support

This module uses [type aliases](https://puppet.com/docs/puppet/5.4/lang_type_aliases.html) so it requires a Puppet version >= 4.4.0. This module should work on any *nix system.

## Dependencies

This module relies on `puppetlabs/stdlib` >= 4.12.0 due to its use of the `Stdlib::Absolutepath` type. This module also depends on `puppetlabs/inifile` in order to manage entries in `puppet.conf`.

## Usage

The report processor will be installed during pluginsync. In order to use the report processor you need to add `extended_http` to the list of report processors using the `reports` setting in `puppet.conf`. You'll also need to place a configuration file in `/etc/puppetlabs/puppet/extended_http.yaml` (this path my vary depending on where your `confdir` is set but it'll always be in `$confdir/extended_http.yaml`).

### Configuring Puppet

Here's an example snippet from `puppet.conf`. You'll need to set the `report` and `reports` settings like so:

```ini
# /etc/puppetlabs/puppet/puppet.conf
[master]
report = true
reports = store, extended_http
```

The `extended_http_report_processor` class will configure these values for you if you set the `enable` parameter to `true` (this is the default).

```puppet
class { 'extended_http_report_processor':
  enable    => true,
  endpoints => [
    'http://endpoint1.example.com/upload',
    'https://endpoint2.example.com:8080/reports',
  ]
}
```

If you'd prefer to manage these settings yourself, you should set `enable` to `false`.

```puppet
class { 'extended_http_report_processor':
  enable    => false,
  endpoints => [
    'http://endpoint1.example.com/upload',
    'https://endpoint2.example.com:8080/reports',
  ]
}
```

### Configuring Endpoints

You'll also need to create `/etc/puppetlabs/puppet/extended_http.yaml` and specify your endpoints. You can do this one of two ways. If you just want to specify multiple endpoints and accept the default configuration (namely: content-type = yaml) you can simply pass an array to the `endpoints` key like so:

```yaml
---
endpoints:
  - http://endpoint1.example.com/upload
  - https://endpoint2.example.com:8080/reports
```

Of course, you may use the `endpoints` parameter on the `extended_http_report_processor` class to configure this file like so:

```puppet
class { 'extended_http_report_processor':
  endpoints => [
    'http://endpoint1.example.com/upload',
    'https://endpoint2.example.com:8080/reports',
  ]
}
```

If you want to be able to configure options for your endpoints, you must pass a hash to the `endpoints` key with the url as the key and a hash of configuration options as the value. Please see `types/endpoint.pp` for documentation of the schema.

```yaml
---
endpoints:
  'http://endpoint1.example.com/upload':
    format: 'json'
    username: 'foo'
    password: 'bar'
  'https://endpoint2.example.com:8080/reports':
    format: 'yaml'
    headers:
      'Authorization': 'f29cf5da-bb8a-428a-85e2-543d7524640c'
```

You can achieve the same outcome using the `extended_http_report_processor` class like this:

```puppet
class { 'extended_http_report_processor':
  endpoints => {
    'http://endpoint1.example.com/upload' => {
      'format'   => 'json',
      'username' => 'foo',
      'password' => 'bar',
    },
    'https://endpoint2.example.com:8080/reports' => {
      'format'  => 'yaml',
      'headers' => { 'Authorization' => 'f29cf5da-bb8a-428a-85e2-543d7524640c' },
    },
  }
}
```

## Development

1. Fork it
2. Create a feature branch
3. Write a failing test
4. Write the code to make that test pass
5. Refactor the code
6. Submit a pull request

We politely request (demand) tests for all new features. Pull requests that contain new features without a test will not be considered. If you need help, just ask!
