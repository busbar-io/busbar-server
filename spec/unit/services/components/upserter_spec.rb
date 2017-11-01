require 'rails_helper'

RSpec.describe Components::Upserter do
  describe '.call' do
    let(:environment) { Environment.new(default_node_id: '1x.standard') }
    let(:data) { { type: 'web', node_id: '1x.standard', command: 'bundle exec rails c' } }
    let(:component) { Component.new(type: 'web', environment_id: environment&.id) }

    subject { described_class.call(environment, data) }

    before do
      allow(Component).to receive(:find_by)
        .with(environment_id: component.environment_id, type: component.type)
        .and_return(component)
      allow(ComponentService).to receive(:install).with(component).and_return(component)
      allow(component).to receive(:valid?).and_return(true)
      allow(component).to receive(:save).and_return(component)
      allow(component).to receive(:assign_attributes).with(data).and_return(component)
    end

    it 'installs the component' do
      expect(ComponentService).to receive(:install).with(component)
      subject
    end

    it 'returns the new/updated component' do
      is_expected.to eq(component)
    end

    it 'updates the component with the data sent' do
      expect(component).to receive(:assign_attributes).with(data).once

      subject
    end

    context 'when the environment is not defined' do
      let(:environment) { nil }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when the type is not defined' do
      let(:data) { Hash.new }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when the node_id of the component differs from the one of the environment' do
      let(:component) do
        Component.new(type: data[:type], environment_id: environment.id, node_id: '2x.standard')
      end

      it 'only updates the component with the other keys of the data hash' do
        expect(component).to receive(:assign_attributes)
          .with(type: 'web', command: 'bundle exec rails c').once

        subject
      end
    end

    context 'when the component does not exist' do
      before do
        allow(Component).to receive(:find_by)
          .with(environment_id: component.environment_id, type: component.type)
          .and_raise Mongoid::Errors::DocumentNotFound.new(Component, component.id)

        allow(Component).to receive(:new)
          .with(environment_id: environment.id, type: 'web')
          .and_return(Component.new)
      end

      it 'creates a new component' do
        expect(Component).to receive(:new).with(environment_id: environment.id, type: 'web')

        subject
      end
    end

    context 'when the components should be resized' do
      subject { described_class.call(environment, data, resize_components: true) }

      it 'updates the component with the data sent' do
        expect(component).to receive(:assign_attributes).with(data).once

        subject
      end

      context 'when the node_id of the component differs from the one of the environment' do
        let(:component) do
          Component.new(type: data[:type], environment_id: environment.id, node_id: '2x.standard')
        end

        it 'only updates the component with all of the data hash attributes' do
          expect(component).to receive(:assign_attributes)
            .with(data).once

          subject
        end
      end
    end
  end
end
