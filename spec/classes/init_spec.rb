require 'spec_helper'

describe 'nginx_proxy' do

  describe ' with sample settings' do

    context 'on Red Hat 7' do
      let :facts do
        {
          :kernel                    => 'Linux',
          :osfamily                  => 'RedHat',
          :operatingsystem           => 'RedHat',
          :operatingsystemmajrelease => '7',
        }
      end

      let :pre_condition do
        "package {'nginx':
           ensure => installed,
         }

         class {'::nginx_proxy':
          locations => [
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
        }"
      end

      it { is_expected.to compile }

      it {
        should contain_class('nginx_proxy').with(
          'config_file'       => '/etc/nginx/nginx.conf',
        )
      }

      it 'should create upstream old_backend_http' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+upstream old_backend_http \{\n\s+server 127.0.0.1:8081;\n\s+\}/)
      end

      it 'should create upstream old_backend_https' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+upstream old_backend_https \{\n\s+server 127.0.0.1:8444;\n\s+\}/)
      end

      it 'should create upstream new_backend_https' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+upstream new_backend_https \{\n\s+ip_hash;\n\s+server 127.0.0.1:9444;\n\s+server 127.0.0.1:10444;\n\s+\}/)
      end

      it 'should create http redirect for /part3' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+location \/part3 \{\n\s+# Order defined in Puppet: 005\n\s+return 301 https:\/\/\$host:443\$request_uri;\n\s+\}/)
      end

      it 'should create http default http location' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+location \/ \{\n\s+# Order defined in Puppet: 999\n\s+proxy_pass http:\/\/old_backend_http;(.|\n)*\n\s+proxy_set_header.*forwarded_for;\n\s+\}/)
      end

      it 'should order all locations sections numerically' do
         should contain_file('/etc/nginx/nginx.conf').with_content(/# Order.*: 005\n\s+return(.|\n)*# Order.*: 999\n\s+proxy_pass.*_http;\n(.|\n)*# Order.*: 005\n\s+proxy_pass.*_https;(.|\n)*# Order.*: 999\n\s+proxy_pass.*_https;/)
      end

    end

  end

end
