require 'rails_helper'
require 'webmock/rspec'

RSpec.describe EnvironmentDestroyProcessing do
  describe '.perform' do
    subject { described_class.new.perform(environment.id) }

    before do
      allow(EnvironmentService).to receive(:destroy)
      allow(HookService).to receive(:call)
    end

    let(:environment) { Environment.new(id: 'some_env_id', name: 'staging') }

    context 'when the given environment exists' do
      let(:environment_id) { environment.id }

      let!(:components) do
        [
          Component.new,
          Component.new,
          Component.new
        ]
      end

      before do
        allow(environment).to receive(:components).and_return(components)
        allow(environment).to receive(:destroy).and_return(true)
        allow(Environment).to receive(:find).with(environment.id).and_return(environment)
        allow(EnvironmentService).to receive(:destroy_components)
        allow(PrivateInterfaceService).to receive(:destroy)
        allow(PublicInterfaceService).to receive(:destroy)
        allow(NamespaceService).to receive(:destroy)
      end

      it "destroys the environment's components" do
        subject

        expect(EnvironmentService).to have_received(:destroy_components).with(environment).once
      end

      it "destroys the environment's ingress controller" do
        subject

        expect(PrivateInterfaceService).to have_received(:destroy).with(environment).once
      end

      it "destroys the environment's public service" do
        subject

        expect(PublicInterfaceService).to have_received(:destroy).with(environment).once
      end

      it "destroys the environment's namespace" do
        subject

        expect(NamespaceService).to have_received(:destroy).with(environment.namespace).once
      end

      it 'destroys the environment' do
        subject

        expect(environment).to have_received(:destroy).once
      end

      it 'creates a notification about the environment destruction' do
        expect(HookService).to receive(:call)
          .with(resource: environment, action: 'destroy', value: 'success')

        subject
      end
    end

    context 'when the given environment does not exist' do
      before do
        allow(Environment).to receive(:find).with(environment.id).and_raise(error)
      end

      let(:error) { Mongoid::Errors::DocumentNotFound.new(Environment, [environment.id]) }

      it 'returns false' do
        expect { subject }
          .to raise_error(EnvironmentDestroyProcessing::EnvironmentNotFound)
      end

      it 'does not create a notification about the environment deploy' do
        begin
          subject
        rescue EnvironmentDestroyProcessing::EnvironmentNotFound
          expect(HookService).to_not have_received(:call)
        end
      end
    end
  end
end
