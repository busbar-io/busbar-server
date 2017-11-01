require 'rails_helper'

RSpec.describe Deployments::Processor::BuildInjector do
  describe '.call' do
    let(:build) { Build.new }
    let(:environment) { Environment.new }
    let(:deployment) do
      Deployment.new(environment: environment, buildpack_id: 'ruby', branch: 'master')
    end
    let(:build_data) { { buildpack_id: deployment.buildpack_id, branch: deployment.branch } }

    subject { described_class.call(deployment) }

    before do
      allow(BuildService).to receive(:create).with(environment, build_data).and_return(build)
      allow(deployment).to receive(:build=).with(build).and_return(build)
      allow(deployment).to receive(:save).and_return(true)
    end

    it 'injects the build into a given Deployment' do
      is_expected.to eq(deployment)
    end

    context 'when it fails to inject the build into the given Deployment' do
      let(:error) { Deployments::Processor::BuildInjector::BuildInjectionError }

      context 'when the deployment can not be saved' do
        before do
          allow(deployment).to receive(:save).and_return(false)
        end

        it 'raises a BuildInjectionError error' do
          expect { subject }.to raise_error(error)
        end
      end

      context 'when the build is broken' do
        before do
          allow(deployment).to receive(:save).and_return(true)
          allow(build).to receive(:state).and_return('broken')
        end

        it 'raises a BuildInjectionError error' do
          expect { subject }.to raise_error(error)
        end
      end
    end
  end
end
