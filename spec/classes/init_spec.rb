require 'spec_helper'

describe 'stackdriver' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }

      it do
        is_expected.to contain_class("::$name::install::$lower_osfamily")
            .with({
              "ensure" => "present",
              "notify" => "Class[$name::service]",
              })
      end

      it do
        is_expected.to contain_class("::$name::config::$lower_osfamily")
            .with({
              "require" => "Class[$name::install::$lower_osfamily]",
              })
      end

      it do
        is_expected.to contain_class("::$name::service")
            .with({
              "service_ensure" => "running",
              "service_enable" => true,
              "require" => "Class[$name::config::$lower_osfamily]",
              })
      end

      it do
        is_expected.to contain_stackdriver__plugin("$plugins")
      end
    end
  end
end
