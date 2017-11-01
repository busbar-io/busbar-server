require 'rails_helper'
require 'webmock/rspec'

RSpec.describe PrivateInterfaces::Destroyer do
  describe '.call' do
    subject { described_class.call(environment) }

    let(:environment) do
      double(:environment, name: 'staging', app_id: 'test', namespace: 'staging')
    end

    let(:command) do
      "kubectl delete svc #{environment.app_id}-#{environment.name}-private "\
      "--namespace=#{environment.namespace}"
    end

    before do
      allow_any_instance_of(described_class).to receive(:system)
        .with(command)
        .and_return(true)
    end

    context 'when the deletion is a success' do
      it 'runs the command to delete the service' do
        allow_any_instance_of(described_class).to receive(:system).with(command).and_return(true)

        expect_any_instance_of(described_class).to receive(:system).with(command)

        subject
      end
    end

    context 'when the deletion fails' do
      it 'raises a DestructionError' do
        allow_any_instance_of(described_class).to receive(:system).with(command).and_return(false)

        expect { subject }.to raise_error(described_class::DestructionError)
      end
    end
  end
end
