require 'rails_helper'

RSpec.describe Hooks::HookSerializer do
  let(:resource) do
    double(
      :resource,
      attribute_1: 'a_value',
      attribute_2: 'another_value',
      a_non_serialized_attribute: 'a_non_serialized_value',
      class: double(:class, name: 'Resource')
    )
  end

  context 'when the implementation implements the serialized_attributes method' do
    subject { HookSerializerImplementation.call(resource) }

    before do
      class HookSerializerImplementation < Hooks::HookSerializer
        def serialized_attributes
          %w(attribute_1 attribute_2)
        end
      end
    end

    it 'serializes the resource' do
      expect(subject).to match(
        resource_attribute_1: 'a_value',
        resource_attribute_2: 'another_value'
      )
    end
  end

  context 'when the implementation does not implement the serialized_attributes method' do
    subject { WrongHookSerializerImplementation.call(resource) }

    before do
      class WrongHookSerializerImplementation < Hooks::HookSerializer
      end
    end

    it 'raises an error' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end
end
