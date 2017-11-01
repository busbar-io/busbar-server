require 'rails_helper'

RSpec.describe ScaleProcessing do
  describe '#perform' do
    let(:component_id) { 'web' }
    let(:scale) { 3 }
    let(:environment) { Environment.new }
    let(:component) { Component.new(id: component_id, environment_id: environment.id) }

    subject { described_class.new.perform(component_id, scale) }

    before do
      allow(Component).to receive(:find).and_return(component)
      allow(Environment).to receive(:find).and_return(environment)
      allow(LockService).to receive(:synchronize).with(environment_id: environment.id).and_yield
      allow(ComponentService).to receive(:scale).with(component, scale)
    end

    it 'scales the component' do
      expect(ComponentService).to receive(:scale).with(component, scale)
      subject
    end

    context 'when the component does not exist' do
      let(:error) { Mongoid::Errors::DocumentNotFound.new(Component, [component.id]) }

      before do
        allow(Component).to receive(:find).and_raise(error)
      end

      it 'raises a ComponentNotFound error' do
        expect { subject }.to raise_error(ScaleProcessing::ComponentNotFound)
      end
    end

    context 'when the environment does not exist' do
      let(:error) { Mongoid::Errors::DocumentNotFound.new(Environment, [environment.id]) }

      before do
        allow(Environment).to receive(:find).and_raise(error)
      end

      it 'raises an AppNotFound error' do
        expect { subject }.to raise_error(ScaleProcessing::EnvironmentNotFound)
      end
    end
  end
end
