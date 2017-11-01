require 'rails_helper'

RSpec.shared_examples Buildpack do
  describe '.call' do
    let(:build_cmd) do
      "cd #{build.path} && docker build --force-rm --rm --tag=#{build.image_tag} --no-cache ."
    end

    subject { described_class.call(build) }

    before do
      allow(File).to receive(:exist?)
      allow(IO).to receive(:write)
      allow_any_instance_of(described_class).to receive(:system).with(build_cmd).and_return(true)
      allow_any_instance_of(described_class).to receive(:compile)
      allow(CommandExecutorAndLogger).to receive(:call)
    end

    it 'compiles the buildpack' do
      expect_any_instance_of(described_class).to receive(:compile)
      subject
    end

    it 'builds the image' do
      expect(CommandExecutorAndLogger).to receive(:call).with(build_cmd, build.log).once
      subject
    end
  end
end
