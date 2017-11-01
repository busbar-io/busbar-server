require 'rails_helper'

RSpec.describe DeploymentProcessing do
  describe '#perform' do
    let(:deployment) { Deployment.new(environment_id: 'test') }
    let(:data)       { { environment_id: deployment.environment_id } }
    let(:options) { { resize_components: true } }

    subject { described_class.new.perform(deployment.id, options) }

    before do
      allow(Deployment).to receive(:find).with(deployment.id).and_return(deployment)
      allow(LockService).to receive(:synchronize).with(data).and_yield
      allow(DeploymentService).to receive(:process)
    end

    it 'processes a given Deployment' do
      expect(DeploymentService).to receive(:process).with(deployment, options)
      subject
    end

    context 'when the Deployment processing fails' do
      before do
        allow(DeploymentService).to receive(:process).and_raise('rabble rabble')
        allow(deployment).to receive(:fail!)
      end

      it 'changes the Deployment state to failed' do
        expect(deployment).to receive(:fail!)
        subject
      end
    end

    context 'when the Deployment does not exist' do
      let(:error) { Mongoid::Errors::DocumentNotFound.new(Deployment, [deployment.id]) }

      before do
        allow(Deployment).to receive(:find).and_raise(error)
      end

      it 'raises the error DeploymentNotFound' do
        expect { subject }.to raise_error(DeploymentProcessing::DeploymentNotFound)
      end
    end
  end
end
