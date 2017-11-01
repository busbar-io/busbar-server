require 'rails_helper'

RSpec.describe AppProcessing do
  describe '#perform' do
    let(:options) { { default_env: 'staging' } }
    let(:data) { {} }

    subject { described_class.new.perform(data, options, environment_params) }

    before do
      allow(LockService).to receive(:synchronize).and_yield
      allow(AppService).to receive(:process)
    end

    context 'when an option param is given' do
      let(:environment_params) { {} }

      it 'processes the application data with the given params' do
        expect(AppService).to receive(:process).with(data, options)
        subject
      end
    end

    context 'when an environment params is given' do
      let(:environment_params) { { environment: { name: 'foo' } } }

      it 'processes the application data with the given params' do
        expect(AppService).to receive(:process).with(data, environment_params[:environment])
        subject
      end
    end
  end
end
