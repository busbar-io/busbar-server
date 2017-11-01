require 'rails_helper'

RSpec.describe Builds::Compiler::SlugGenerator do
  describe '.call' do
    let(:buildpack) { Class.new { include Buildpack } }
    let(:build)     { Build.new }

    subject { described_class.call(build) }

    before do
      allow(BuildpackService).to receive(:resolve).with(build.buildpack_id).and_return(buildpack)
      allow(buildpack).to receive(:call).with(build).and_return(true)
    end

    it 'builds the buildpack' do
      expect(buildpack).to receive(:call).with(build)
      subject
    end

    it 'returns the build' do
      expect(subject).to eq(build)
    end

    context 'when it fails to build the buildpack' do
      before do
        allow(buildpack).to receive(:call).and_return(false)
      end

      it 'raises a SlugGenerationError' do
        expect { subject }.to raise_error(Builds::Compiler::SlugGenerator::SlugGenerationError)
      end
    end

    context "when there's a error compiling the build" do
      before do
        allow(buildpack).to receive(:call).and_raise(Buildpack::CompileError)
      end

      it 'raises a SlugGenerationError' do
        expect { subject }.to raise_error(Builds::Compiler::SlugGenerator::SlugGenerationError)
      end
    end
  end
end
