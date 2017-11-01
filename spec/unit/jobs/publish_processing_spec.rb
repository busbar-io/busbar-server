require 'rails_helper'

RSpec.describe PublishProcessing do
  describe '#perform' do
    let(:environment) do
      instance_double(
        Environment,
        id: SecureRandom.hex,
        app_id: 'some_app',
        name: 'staging',
        namespace: 'staging'
      )
    end

    subject { described_class.new.perform(environment.id) }

    before do
      allow(Environment).to receive(:find).with(environment.id).and_return(environment)
      allow(LockService).to receive(:synchronize).and_yield
      allow(PublicInterfaceService).to receive(:create)
      allow(environment).to receive(:update_attributes).and_return(true)
    end

    it 'publishes the given Environment' do
      subject

      expect(PublicInterfaceService).to have_received(:create)
        .with(
          app_name: environment.app_id,
          environment_name: environment.name,
          namespace: environment.namespace
        )
    end

    context 'when the Environment does not exist' do
      let(:error) { Mongoid::Errors::DocumentNotFound.new(Environment, [environment.id]) }

      before do
        allow(Environment).to receive(:find).with(environment.id).and_raise(error)
      end

      it 'raises the error EnvironmentNotFound' do
        expect { subject }.to raise_error(PublishProcessing::EnvironmentNotFound)
      end
    end
  end
end
