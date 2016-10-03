require 'spec_helper'

describe 'stackdriver' do
  on_supported_os.each do |os, facts|

    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }

      let (:name) { 'stackdriver' }
      let (:upper_name) { 'Stackdriver' }
      let (:lower_osfamily) { "#{facts[:osfamily]}".downcase }
      let (:upper_osfamily) { "#{facts[:osfamily]}".downcase.capitalize }
      all_plugins = Array[
        'apache',
        'elasticsearch',
        'exec',
        'memcached',
        'mongo',
        'nginx',
        'postgres',
        'rabbitmq',
        'redis',
        'tomcat',
        'zookeeper',
      ]
      all_services = Array[
        'stackdriver-agent',
        'stackdriver-extractor',
      ]

      context 'with defaults for all parameters' do
        it {
          should contain_class("#{name}::install::#{lower_osfamily}")
            .with({
              "ensure" => "present",
              "notify" => "Class[#{upper_name}::Service]",
          })
        }

        it {
          should contain_class("#{name}::config::#{lower_osfamily}")
            .with({
              "require" => "Class[#{upper_name}::Install::#{upper_osfamily}]",
          })
        }

        it {
          should contain_package('stackdriver-agent')
            .with({ "ensure" => "present" })
        }

        context "all services enabled and running" do
          all_services.each do |svc|
            context "#{svc}" do
              it {
                should contain_service("#{svc}")
                  .with({
                    "ensure" => "running",
                    "enable" => true,
                  })
              }
            end
          end
        end

      end

      context "with all plugins activated" do
        all_plugins.each do |plugin|
          context "#{plugin}" do
            let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
            hiera = Hiera.new(:config => 'spec/fixtures/hiera/hiera.yaml')

            it { should contain_class("#{name}::plugin::#{plugin}") }
          end
        end
      end

      context 'with service_ensure set to stopped and service_enable set to false' do
        let (:params) { {
          :service_ensure => "stopped",
          :service_enable => false,
        } }

        context "all services stopped" do
          all_services.each do |svc|
            context "#{svc}" do
              it {
                should contain_service("#{svc}")
                  .with({
                    "ensure" => "stopped",
                    "enable" => false,
                  })
              }
            end
          end
        end
      end

      case facts[:osfamily]
      when 'Debian'
        let (:apt_key) { 'B10FDCDCEC088467D0069F423C6E15887B190BD2' }
        let (:apt_key_source) { 'https://app.stackdriver.com/RPM-GPG-KEY-stackdriver' }
        let (:apt_location) { 'http://repo.stackdriver.com/apt' }

        context 'with defaults for all parameters' do
          context 'default service configuration file' do
            it {
              should contain_file('/etc/default/stackdriver-agent')
                .with({
                  'ensure'  => 'file',
                  'owner'   => 'root',
                  'group'   => 'root',
                  'mode'    => '0440',
                  'notify'  => [
                    "Service[stackdriver-agent]",
                    "Service[stackdriver-extractor]",
                  ],
              })
            }
          end
        end

        context 'with managerepo set to true' do
          let (:params) { { :managerepo => true } }

          it {
            should contain_apt__key('stackdriver')
              .with({
                'key'        => "#{apt_key}",
                'key_source' => "#{apt_key_source}",
            })
          }

          it {
            should contain_apt__source('stackdriver')
              .with({
                'location' => "#{apt_location}",
                'release'  => "#{facts[:lsbdistcodename]}",
                'repos'    => 'main',
                'key'      => "#{apt_key}",
            })
          }
        end

        context 'with managerepo set to false' do
          let (:params) { { :managerepo => false } }

          it { should_not contain_class('apt::key') }
          it { should_not contain_class('apt::source') }
        end

        context 'with ensure set to absent' do
          let (:params) { { :ensure => "absent" } }

          it {
            should contain_package('stackdriver-agent')
              .with({ "ensure" => "absent" })
          }
        end

        context 'with apikey set' do
          let (:params) { { :apikey => "abc1234" } }

          it {
            should contain_file('/etc/default/stackdriver-agent')
              .with_content(/STACKDRIVER_API_KEY="abc1234"/)
          }
        end

      when 'RedHat'

        context 'with defaults for all parameters' do
          context 'default service configuration file' do
            it {
              should contain_file('/etc/sysconfig/stackdriver')
                .with({
                  'ensure'  => 'file',
                  'owner'   => 'root',
                  'group'   => 'root',
                  'mode'    => '0440',
                  'notify'  => [
                    "Service[stackdriver-agent]",
                    "Service[stackdriver-extractor]",
                  ],
              })
            }
          end
        end

        context 'with managerepo set to true' do
          let (:params) { { :managerepo => true } }

          it {
            should contain_yumrepo('stackdriver-agent')
              .with({
                'baseurl'  => "http://repo.stackdriver.com/repo/el#{facts[:operatingsystemmajrelease]}/\$basearch/",
                'gpgkey'   => 'https://www.stackdriver.com/RPM-GPG-KEY-stackdriver',
                'descr'    => 'stackdriver',
                'enabled'  => 1,
                'gpgcheck' => 1,
            })
          }
        end

        context 'with managerepo set to false' do
          let (:params) { { :managerepo => false } }

          it { should_not contain_yumrepo('stackdriver-agent') }
        end

        context 'with ensure set to absent' do
          let (:params) { { :ensure => "absent" } }

          it {
            should contain_package('stackdriver-agent')
              .with({ "ensure" => "absent" })
          }

          it {
            should contain_package('stackdriver-extractor')
              .with({ "ensure" => "absent" })
          }
        end

        context 'with apikey set' do
          let (:params) { { :apikey => "abc1234" } }

          it {
            should contain_file('/etc/sysconfig/stackdriver')
              .with_content(/STACKDRIVER_API_KEY="abc1234"/)
          }
        end


      end

    end
  end
end
