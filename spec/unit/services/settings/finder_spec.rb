require 'rails_helper'

RSpec.describe Settings::Finder do
  describe '.call' do
    let(:settings) { { test_key: 'test_value' } }
    let(:environment) { Environment.new(settings: settings) }
    let(:data) { { key: 'test_key' } }

    subject { described_class.call(environment, data) }

    it 'returns a setting' do
      result = subject
      expect(result.key).to eq 'test_key'
      expect(result.value).to eq 'test_value'
    end

    context 'when the setting is not defined' do
      let(:data) { { key: 'does_not_exist' } }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end
end
