require 'rails_helper'

RSpec.describe Buildpacks::Resolver do
  describe '.call' do
    subject { described_class.call(buildpack_id) }

    context 'when the buildpack does not exist' do
      let(:buildpack_id) { 'invalid' }

      it 'fails with Buildpacks::Resolver::InvalidBuildpack exception' do
        expect { subject }.to raise_error(Buildpacks::Resolver::InvalidBuildpack)
      end
    end

    context 'when the buildpack exists' do
      let(:buildpack_id) { 'ruby' }

      it 'returns the buildpack for the given buildpack id' do
        is_expected.to be_a(RubyBuildpack)
      end
    end
  end
end
