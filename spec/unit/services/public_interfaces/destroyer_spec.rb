require 'rails_helper'
require 'webmock/rspec'

RSpec.describe PublicInterfaces::Destroyer do
  describe '.call' do
    subject { described_class.call(environment) }

    let(:environment) do
      Environment.new(
        _id: 'staging',
        app_id: 'some_app',
        public: public,
        buildpack_id: 'ruby',
        name: namespace,
        settings: {
          'MONGO_URL': 'mongodb://test',
          'REDIS_URL': 'redis://test'
        }
      )
    end

    let(:namespace) { 'staging' }

    before do
      allow(Environment).to receive(:find).and_return(environment)
    end

    after do
      environment.destroy
    end

    let(:command) do
      "kubectl delete svc #{environment.app_id}-#{environment.id}-public " \
      "--namespace=#{environment.namespace}"
    end

    context 'when the environment is public' do
      let(:public) { true }

      before do
        allow_any_instance_of(described_class).to receive(:system).with(command).and_return(success)
      end

      context 'and the deletion is a success' do
        let(:success) { true }

        it 'runs the command to delete its public interface' do
          expect_any_instance_of(described_class).to receive(:system).with(command)

          subject
        end
      end

      context 'and the deletion fails' do
        let(:success) { false }

        it 'raises a DestructionError' do
          allow_any_instance_of(described_class).to receive(:system).with(command).and_return(false)

          expect { subject }
            .to raise_error(described_class::DestructionError)
        end
      end
    end

    context 'when the environment is private' do
      let(:public) { false }

      it 'does not try to deleve its public interface' do
        allow_any_instance_of(described_class).to receive(:system).with(command)

        expect_any_instance_of(described_class).to_not receive(:system).with(command)

        subject
      end
    end
  end
end
