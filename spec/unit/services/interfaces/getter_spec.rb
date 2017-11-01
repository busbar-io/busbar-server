require 'rails_helper'

RSpec.describe Interfaces::Getter do
  describe '.call' do
    subject { described_class.call(service_name, namespace) }

    let(:service_name) { 'app-environment-public' }
    let(:namespace) { 'staging' }

    context 'succeeds on fetching the hostname' do
      before do
        allow_any_instance_of(described_class)
          .to receive(:`)
          .with("kubectl get svc/#{service_name} --namespace=#{namespace} -o json")
          .and_return(command_response)

        allow(JSON).to receive(:parse).with(command_response).and_return(
          'status' => {
            'loadBalancer' => {
              'ingress' => [
                { 'hostname' => 'some_hostname' }
              ]
            }
          }
        )
      end

      let(:command_response) { 'a string' }

      it 'returns a hash containing the hostname of the given name' do
        expect(subject).to eq(hostname: 'some_hostname')
      end
    end

    context 'when it fails to fetch the hostname' do
      before do
        allow_any_instance_of(described_class)
          .to receive(:`)
          .with("kubectl get svc/#{service_name} --namespace=#{namespace} -o json")
          .and_raise(StandardError.new)

        allow_any_instance_of(described_class).to receive(:sleep)
      end

      it 'raises a PublicInterfaceGettingError if the error persists 5 times' do
        expect_any_instance_of(described_class).to receive(:sleep).with(1).exactly(5).times

        expect { subject }.to raise_error(Interfaces::Getter::InterfaceGettingError)
      end
    end
  end
end
