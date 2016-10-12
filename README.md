[![Build Status][travis-img-master]][travis-ci]
[![Puppet Forge][pf-img]][pf-link]
[![GitHub tag][gh-tag-img]][gh-link]

# nginx_proxy

#### Table of Contents

1. [Overview](#overview)
2. [Setup requirements](#setup-requirements)
3. [Beginning with nginx_proxy](#beginning-with-nginx_proxy)
4. [Settings](#settings)
5. [License](#license)
6. [Contributing](#contributing)


## Overview

This module is a small utility module that does nothing but configure
`nginx.conf`. It is designed to make Nginx act as a reverse proxy similar to
the one in [https://github.com/genebean/nginx-uri-proxy][nginx-uri-proxy].


## Setup requirements

Nginx must be installed and its services must be managed elsewhere. The
`required_packages` parameter can be used to make sure this runs after the
package is installed.


## Beginning with nginx_proxy

The bulk of the settings for this module are contained in a pair of hashes.
It is recommended to take advantage of Hiera to store these as it takes a lot
less effort than creating the same structure in a manifest.

## Settings

Below are all the settings this module uses and their default values.

### Module-specific settings

```puppet
$locations                 = [],
$required_packages         = ['nginx'],
$upstreams                 = [],
```

#### `locations`

This is a hash that correlates to the location blocks in `nginx.conf`.

* `order`: Controls what order the blocks are placed in the config (required)
* `exact`: Whether the path matching is an exact match or a starts with match (required)
* `path`: The path the location block matches (required)
* `redirect`: Whether the path redirects to https or not (required)
* `http_upstream`: If redirect is false then this is the upstream used (optional)
* `https_upstream`: The upstream to use for https connections (required)


#### `upstreams`

* `title`: The name of the upstream (required)
* `lb_method`: The load balancing algorithm to use (optional)
* `servers`: An array of servers to send the traffic to (required)


##### Examples:

```puppet
locations => [
  {
    order          => '001',
    exact          => true,
    path           => '/',
    redirect       => true,
    https_upstream => 'new_backend_https',
  },
  {
    order          => '002',
    exact          => true,
    path           => '/index.php',
    redirect       => true,
    https_upstream => 'new_backend_https',
  },
  {
    order          => '003',
    exact          => false,
    path           => '/part1',
    redirect       => true,
    https_upstream => 'new_backend_https',
  },
  {
    order          => '004',
    exact          => true,
    path           => '/part2/special/page.php',
    redirect       => true,
    https_upstream => 'new_backend_https',
  },
  {
    order          => '999',
    exact          => false,
    path           => '/',
    redirect       => false,
    http_upstream  => 'old_backend_http',
    https_upstream => 'old_backend_https',
  },
  {
    order          => '005',
    exact          => false,
    path           => '/part3',
    redirect       => true,
    https_upstream => 'new_backend_https',
  },
],
upstreams => [
  {
    title   => 'old_backend_http',
    servers => [
      '127.0.0.1:8081',
    ],
  },
  {
    title   => 'old_backend_https',
    servers => [
      '127.0.0.1:8444',
    ],
  },
  {
    title     => 'new_backend_https',
    lb_method => 'ip_hash',
    servers   => [
      '127.0.0.1:9444',
      '127.0.0.1:10444',
    ],
  },
],
```

```yaml
---
nginx_proxy::locations:
  - order          : '001'
    exact          : true
    path           : '/'
    redirect       : true
    https_upstream : 'new_backend_https'
  - order          : '999'
    exact          : false
    path           : '/'
    redirect       : false
    http_upstream  : 'old_backend_http'
    https_upstream : 'old_backend_https'
nginx_proxy::upstreams:
  - title   : 'old_backend_http'
    servers :
      - '127.0.0.1:8081'
  - title   : 'old_backend_https'
    servers :
      - '127.0.0.1:8444'
  - title     : 'new_backend_https'
    lb_method : 'ip_hash'
    servers   :
      - '127.0.0.1:9444'
      - '127.0.0.1:10444'
```


### Nginx-specific settings

```puppet
$access_log                = '/var/log/nginx/access.log',
$config_file               = '/etc/nginx/nginx.conf',
$docroot                   = '/usr/share/nginx/html',
$dynamic_modules           = '/usr/share/nginx/modules/*.conf',
$error_log                 = '/var/log/nginx/error.log',
$mime_include              = '/etc/nginx/mime.types',
$pid_file                  = '/run/nginx.pid',
$port_http                 = 80,
$port_https                = 443,
$server_name              = '_',
$ssl_certificate           = '/etc/pki/tls/certs/localhost.crt',
$ssl_certificate_key       = '/etc/pki/tls/private/localhost.key',
$ssl_session_cache         = 'shared:SSL:1m',
$ssl_session_timeout       = '10m',
$ssl_ciphers               = 'HIGH:!aNULL:!MD5',
$ssl_prefer_server_ciphers = 'on',
$user                      = 'nginx',
$worker_connections        = 1024,
$worker_processes          = 'auto',
```


## License

This is released under the New BSD / BSD-3-Clause license. A copy of the license
can be found in the root of the module.


## Contributing

Pull requests are welcome!


[gh-tag-img]: https://img.shields.io/github/tag/genebean/genebean-nginx_proxy.svg
[gh-link]: https://github.com/genebean/genebean-nginx_proxy
[nginx-uri-proxy]: https://github.com/genebean/nginx-uri-proxy
[pf-img]: https://img.shields.io/puppetforge/v/genebean/nginx_proxy.svg
[pf-link]: https://forge.puppetlabs.com/genebean/nginx_proxy
[travis-ci]: https://travis-ci.org/genebean/genebean-nginx_proxy
[travis-img-master]: https://img.shields.io/travis/genebean/genebean-nginx_proxy/master.svg
