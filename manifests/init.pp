# Creates a simple nginx.conf for a reverse proxy setup
# See exammple.pp for sample usage.
#
class nginx_proxy (
  $access_log                = '/var/log/nginx/access.log',
  $config_file               = '/etc/nginx/nginx.conf',
  $docroot                   = '/usr/share/nginx/html',
  $dynamic_modules           = '/usr/share/nginx/modules/*.conf',
  $error_log                 = '/var/log/nginx/error.log',
  $locations                 = [],
  $mime_include              = '/etc/nginx/mime.types',
  $pid_file                  = '/run/nginx.pid',
  $port_http                 = 80,
  $port_https                = 443,
  $required_packages         = ['nginx'],
  $server_name              = '_',
  $ssl_certificate           = '/etc/pki/tls/certs/localhost.crt',
  $ssl_certificate_key       = '/etc/pki/tls/private/localhost.key',
  $ssl_session_cache         = 'shared:SSL:1m',
  $ssl_session_timeout       = '10m',
  $ssl_ciphers               = 'HIGH:!aNULL:!MD5',
  $ssl_prefer_server_ciphers = 'on',
  $upstreams                 = [],
  $user                      = 'nginx',
  $worker_connections        = 1024,
  $worker_processes          = 'auto',
){
  file { $config_file:
    ensure  => file,
    content => template('nginx_proxy/nginx.conf.erb'),
    owner   => $user,
    require => Package[$required_packages],
  }
}
