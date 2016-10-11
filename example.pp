package { 'nginx':
  ensure => installed,
}
class { '::nginx_proxy':
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
}
