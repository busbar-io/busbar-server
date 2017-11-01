require 'rails_helper'

RSpec.describe Databases::ServiceCreator do
  describe '.call' do
    subject { described_class.call(database) }

    let(:database) do
      instance_double(
        Database,
        id: 'mydb',
        name: 'mydb',
        namespace: 'staging',
        type: 'redis',
        port: 6379,
        role: 'redis-single',
        size: 10
      )
    end

    let(:manifest) do
      {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          name: 'mydb',
          labels: {
            app: 'mydb',
            component: 'redis',
            role: 'redis-single'
          }
        },
        spec: {
          ports: [
            {
              port: 6379,
              targetPort: 6379
            }
          ],
          selector: {
            app: 'mydb',
            component: 'redis',
            role: 'redis-single'
          }
        }
      }
    end

    before do
      allow_any_instance_of(described_class).to receive(:system).and_return(true)
    end

    it 'creates a service' do
      expect_any_instance_of(described_class).to receive(:system)
        .with("echo '#{manifest.to_json}' | "\
               'kubectl create -f - --namespace=staging')

      subject
    end

    context 'when an error happens during the service creation' do
      before do
        allow_any_instance_of(described_class).to receive(:system).and_return(false)
      end

      it 'raises a ServiceCreationError' do
        expect { subject }
          .to raise_error(
            Databases::ServiceCreator::ServiceCreationError
          )
      end
    end
  end
end
