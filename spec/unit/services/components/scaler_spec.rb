require 'rails_helper'

RSpec.describe Components::Scaler do
  describe '.call' do
    let(:scale) { 1 }
    let(:command) do
      "kubectl scale --replicas=#{scale} deployment some_app-staging-worker --namespace=staging"
    end
    let(:component) do
      instance_double(
        Component,
        id: 'some_component_id',
        scale: scale,
        type: 'worker',
        name: 'some_app-staging-worker',
        namespace: 'staging',
        update_attributes: true
      )
    end

    subject { described_class.call(component, scale) }

    before do
      allow_any_instance_of(described_class).to receive(:system).with(command).and_return(true)

      allow(HookService).to receive(:call).with(resource: component, action: 'scale', value: scale)
    end

    it 'scales the component' do
      expect(component).to receive(:update_attributes).with(scale: scale)

      expect_any_instance_of(described_class).to receive(:system).with(command)
      is_expected.to eq component
    end

    it 'notifies about the component scaling' do
      expect(HookService).to receive(:call)
        .with(resource: component, action: 'scale', value: scale)
        .once

      subject
    end

    context 'when it fails to scale the component' do
      before do
        allow_any_instance_of(described_class).to receive(:system).with(command).and_return(false)
      end

      it 'raises a ComponentScalingError error' do
        expect_any_instance_of(described_class).to receive(:system).with(command)
        expect { subject }.to raise_error(Components::Scaler::ComponentScalingError)
      end

      it 'does not notify about the component scaling' do
        begin
          subject
        rescue Components::Scaler::ComponentScalingError
          expect(HookService).to_not have_received(:call)
        end
      end
    end
  end
end
