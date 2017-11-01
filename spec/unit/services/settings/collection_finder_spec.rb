require 'rails_helper'

RSpec.describe Settings::CollectionFinder do
  describe '.call' do
    let(:settings) { Hash.new }
    let(:environment) { Environment.new(settings: settings) }

    subject { described_class.call(environment) }

    context 'when the environment has settings' do
      let(:settings) { { test_key: 'test_value' } }
      let(:result)   { settings.map { |k, v| Setting.new(key: k, value: v) } }

      it 'returns a list of settings' do
        expect(subject).to be_a(Array)
        expect(subject.size).to eq(1)
        expect(subject.first.key).to eq(result.first.key)
        expect(subject.first.value).to eq(result.first.value)
      end
    end

    context 'when the environment does not have settings' do
      it 'returns an empty list' do
        is_expected.to be_empty
      end
    end
  end
end
