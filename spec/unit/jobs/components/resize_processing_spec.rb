require 'rails_helper'

RSpec.describe Components::ResizeProcessing do
  describe '#perform' do
    let(:node_id) { '2x.standard' }
    let(:environment) { Environment.new }
    let(:component) { Component.new(environment: environment) }

    subject { described_class.new.perform(component.id, node_id) }

    before do
      allow(Component).to receive(:find).and_return(component)
      allow(DeploymentService).to receive(:create).with(environment, {}, build: false)
      allow(LockService).to receive(:synchronize).with(component_id: component.id).and_yield
      allow(HookService).to receive(:call)
        .with(resource: component, action: 'resize', value: node_id)
    end

    it 'changes the node type' do
      expect(component).to receive(:update_attributes).with(node_id: node_id)
      subject
    end

    it 'locks the component before changing it' do
      expect(LockService).to receive(:synchronize).with(component_id: component.id).and_yield.once
      subject
    end

    it "redeploys the component's environment" do
      expect(DeploymentService).to receive(:create)
        .with(environment, {}, build: false)
      subject
    end

    it 'notifies the resizing' do
      expect(HookService).to receive(:call)
        .with(resource: component, action: 'resize', value: node_id)
      subject
    end

    context 'when the component does not exist' do
      before do
        allow(Component).to receive(:find).and_raise(
          Mongoid::Errors::DocumentNotFound.new(Component, [component.id])
        )
      end

      it 'raises an ComponentNotFound error' do
        expect { subject }.to raise_error(Components::ResizeProcessing::ComponentNotFound)
      end
    end
  end
end
