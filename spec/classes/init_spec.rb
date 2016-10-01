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

      it do
        is_expected.to contain_class("#{name}::install::#{lower_osfamily}")
          .with({
            "ensure" => "present",
            "notify" => "Class[#{upper_name}::Service]",
        })
      end

      it do
        is_expected.to contain_class("#{name}::config::#{lower_osfamily}")
          .with({
            "require" => "Class[#{upper_name}::Install::#{upper_osfamily}]",
        })
      end

      it do
        is_expected.to contain_class("#{name}::service")
          .with({
            "service_ensure" => "running",
            "service_enable" => true,
            # "require" => "Class[#{upper_name}::config::#{lower_osfamily}]",
        })
      end

      # it do
      #   is_expected.to contain_stackdriver__plugin("$plugins")
      # end
    end
  end
end
