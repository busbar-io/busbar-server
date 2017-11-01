require 'rails_helper'

RSpec.describe ResizeProcessing do
  describe '#perform' do
    let(:node_id)     { '2x.standard' }
    let(:environment) { instance_double(Environment, id: SecureRandom.hex) }

    subject { described_class.new.perform(environment.id, node_id) }

    before do
      allow(Environment).to receive(:find).and_return(environment)
      allow(LockService).to receive(:synchronize).with(environment_id: environment.id).and_yield
      allow(HookService).to receive(:call)
        .with(resource: environment, action: 'resize', value: node_id)
      allow(DeploymentService).to receive(:create)
        .with(environment, {}, build: false, resize_components: true)
      allow(environment).to receive(:update_attributes).and_return(true)
    end

    it 'changes the node type' do
      expect(environment).to receive(:update_attributes).with("default_node_id": node_id)
      subject
    end

    it 'locks the environment before changing it' do
      expect(LockService).to receive(:synchronize)
        .with(environment_id: environment.id)
        .and_yield
        .once

      subject
    end

    it 'redeploys the environment resizing its components' do
      expect(DeploymentService).to receive(:create)
        .with(environment, {}, build: false, resize_components: true)
      subject
    end

    it 'notifies about the resizing' do
      expect(HookService).to receive(:call)
        .with(resource: environment, action: 'resize', value: node_id)

      subject
    end

    context 'when the environment does not exist' do
      let(:error) { Mongoid::Errors::DocumentNotFound.new(Environment, [environment.id]) }

      before do
        allow(Environment).to receive(:find).and_raise(error)
      end

      it 'raises an EnvironmentNotFound error' do
        expect { subject }.to raise_error(ResizeProcessing::EnvironmentNotFound)
      end

      it 'does not notify about the resizeing' do
        begin
          subject
        rescue ResizeProcessing::EnvironmentNotFound
          expect(HookService).to_not have_received(:call)
        end
      end
    end
  end
end
