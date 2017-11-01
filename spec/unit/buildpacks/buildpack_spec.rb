require 'rails_helper'

RSpec.describe Buildpack do
  describe '.call' do
    let(:buildpack) { Class.new { include Buildpack } }
    let(:build)     { Build.new(log: Log.new(content: '')) }

    context 'when not using a custom Dockerfile' do
      subject { buildpack.call(build) }

      before do
        allow(File).to receive(:exist?).with("#{build.path}/Dockerfile").and_return(false)
      end

      it 'raises a NotImplementedError' do
        expect { subject }.to raise_error(NotImplementedError)
      end
    end
  end
end
