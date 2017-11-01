require 'rails_helper'

RSpec.describe Builds::Compiler::SourceCodeRetriever do
  describe '.call' do
    let(:build) { Build.new(repository: 'test.git', branch: 'test', log: Log.new) }

    let(:command) do
      deployment_key_file = Configurations.git.deployment_key_file

      "GIT_SSH_COMMAND='ssh -i #{deployment_key_file}' git clone --progress #{build.repository} --branch #{build.branch} #{build.path}" # rubocop:disable Metrics/LineLength
    end

    subject { described_class.call(build) }

    before do
      allow(CommandExecutorAndLogger).to receive(:call).with(command, build.log).and_return(true)
    end

    it 'retrieves the source code' do
      expect(CommandExecutorAndLogger).to receive(:call).with(command, build.log)
      subject
    end
  end
end
