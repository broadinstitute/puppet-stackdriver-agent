require 'spec_helper'

describe 'stackdriver::service' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }

      it do
        is_expected.to contain_service('stackdriver-agent')
          .with({
            "ensure" => "running",
            "enable" => true,
        })
        is_expected.to contain_service('stackdriver-extractor')
          .with({
            "ensure" => "running",
            "enable" => true,
        })
      end
    end
  end
end
