require 'rails_helper'

RSpec.describe Builds::Compiler::VersionControlInfoRetriever do
  describe '.call' do
    let(:build) { Build.new }

    subject { described_class.call(build) }

    before do
      allow(build).to receive(:path).and_return('/some/build/path')

      allow_any_instance_of(described_class)
        .to receive(:`)
        .with('git -C /some/build/path describe --tags --always --abbrev=0')
        .and_return("0.1.0\n")

      allow_any_instance_of(described_class)
        .to receive(:`)
        .with('git -C /some/build/path rev-parse HEAD')
        .and_return("bc21da2a5d0fd75c9981ced74b40c27f40420977\n")
    end

    it 'updates the given build with the current tag' do
      subject
      expect(build.tag).to eq '0.1.0'
    end

    it 'updates the given build with the current commit hash' do
      subject
      expect(build.commit).to eq 'bc21da2a5d0fd75c9981ced74b40c27f40420977'
    end

    it 'returns the given build' do
      expect(subject).to eq(build)
    end
  end
end
