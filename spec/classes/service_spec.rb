require 'spec_helper'

describe 'stackdriver_service' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }

      it do
        is_expected.to contain_service("$::stackdriver::svc")
            .with({
              "ensure" => "running",
              "enable" => true,
              })
      end
    end
  end
end
