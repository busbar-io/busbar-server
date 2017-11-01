require 'rails_helper'

RSpec.describe Builds::Compiler::SlugRegistrar do
  describe '.call' do
    let(:environment)   { Environment.new }
    let(:build) { Build.new(environment: environment, log: Log.new) }

    let(:command) do
      "docker tag -f #{build.image_tag} #{build.image_url} && docker push #{build.image_url}"
    end

    subject { described_class.call(build) }

    context 'when the image registration fails' do
      before do
        allow(CommandExecutorAndLogger).to receive(:call).with(command, build.log).and_return(false)
      end

      it 'raises a SlugRegistrationError error' do
        expect { subject }.to raise_error(Builds::Compiler::SlugRegistrar::SlugRegistrationError)
      end
    end

    context 'when the image registration is succesful' do
      before do
        allow(CommandExecutorAndLogger).to receive(:call).with(command, build.log).and_return(true)
      end

      it 'pushes the image to the Docker registry' do
        expect(CommandExecutorAndLogger).to receive(:call).with(command, build.log)
        subject
      end
    end
  end
end
