require 'rails_helper'

RSpec.describe Deployments::Creator do
  describe '.call' do
    let(:environment) { Environment.new }
    let(:data)        { Hash.new }
    let(:options)     { Hash.new }
    let(:deployment)  { Deployment.new }

    subject { described_class.call(environment, data, options) }

    before do
      allow(DeploymentFactory)
        .to receive(:call)
        .with(environment, data, options)
        .and_return(deployment)
      allow(DeploymentProcessing).to receive(:perform_async).with(deployment.id.to_s, options)
      allow(DeploymentService).to receive(:process).with(deployment, options)
      allow(deployment).to receive(:save).and_return(deployment)
    end

    it 'creates a deployment' do
      expect(DeploymentFactory).to receive(:call).with(environment, data, options)
      subject
    end

    it 'processes the deployment' do
      expect(DeploymentProcessing).to receive(:perform_async).with(deployment.id, options)
      subject
    end

    context 'when the option for processing synchronously is defined' do
      let(:options) { { sync: true } }

      it 'processes the deployment synchronously' do
        expect(DeploymentService).to receive(:process).with(deployment, options)
        subject
      end
    end

    context 'when the environment is not defined' do
      let(:environment) { nil }

      it 'does not process the deployment' do
        expect(DeploymentService).not_to receive(:process)
        expect(DeploymentProcessing).not_to receive(:perform_async)
        subject
      end
    end

    context 'when the deployment fails to be saved' do
      before do
        allow(deployment).to receive(:save).and_return(false)
      end

      it 'does not process the deployment' do
        expect(DeploymentService).not_to receive(:process)
        expect(DeploymentProcessing).not_to receive(:perform_async)
        subject
      end
    end
  end
end
