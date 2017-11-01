require 'rails_helper'

RSpec.describe BuildFactory do
  describe '.call' do
    let(:settings)    { Hash.new }
    let(:app)         { App.new(repository: 'test.git') }
    let(:environment) { Environment.new(app: app, buildpack_id: 'test') }
    let(:data)        { { branch: 'master' } }

    subject { described_class.call(environment, data) }

    context 'when the Environment is not present' do
      let(:environment) { nil }

      it 'does not inject any boilerplate data' do
        build = subject
        expect(build.environment).to be_nil
        expect(build.repository).to be_nil
        expect(build.branch).to eq data[:branch]
        expect(build.buildpack_id).to be_nil
        expect(build.log).to be_nil
      end
    end

    context 'when the Environment is present' do
      it 'injects the boilerplate data' do
        build = subject
        expect(build.environment).to eq environment
        expect(build.repository).to eq environment.repository
        expect(build.branch).to eq data[:branch]
        expect(build.buildpack_id).to eq environment.buildpack_id
        expect(build.log).to be_a_instance_of(Log)
      end
    end
  end
end
