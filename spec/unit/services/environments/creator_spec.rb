require 'rails_helper'

RSpec.describe Environments::Creator do
  describe '.call' do
    let(:data) { { id: 'test-staging' } }
    let(:app) { App.new(id: 'some_app') }

    let(:environment)  { Environment.new(id: data[:id]) }
    let(:saved_with_success) { true }

    subject { described_class.call(app, data) }

    before do
      allow(EnvironmentFactory).to receive(:call).with(data: data, app: app).and_return(environment)

      allow(environment).to receive(:save).and_return(saved_with_success)

      allow(EnvironmentProcessing).to receive(:perform_async).with(environment.id)
    end

    it 'tries to create the environment' do
      subject

      expect(EnvironmentFactory).to have_received(:call).with(data: data, app: app)

      expect(environment).to have_received(:save)
    end

    it 'returns the environment created' do
      expect(subject).to eq(environment)
    end

    it 'schedules the environment for processing' do
      subject

      expect(EnvironmentProcessing).to have_received(:perform_async).with(environment.id)
    end

    context 'when the environment creation fails' do
      let(:saved_with_success) { false }

      it 'schedules the app for processing' do
        subject

        expect(EnvironmentProcessing).to_not have_received(:perform_async)
      end
    end
  end
end
