require 'rails_helper'

RSpec.describe Databases::ReplicationControllerCreator do
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
        image: 'redis:3.2',
        path: '/data/db',
        size: 10
      )
    end

    let(:manifest) do
      {
        apiVersion: 'v1',
        kind: 'ReplicationController',
        metadata: {
          name: 'mydb',
          labels: {
            app: 'mydb',
            component: 'redis',
            role: 'redis-single'
          }
        },
        spec: {
          replicas: 1,
          selector: {
            app: 'mydb',
            component: 'redis',
            role: 'redis-single'
          },
          template: {
            metadata: {
              labels: {
                app: 'mydb',
                component: 'redis',
                role: 'redis-single'
              }
            },
            spec: {
              containers: [
                {
                  name: 'redis',
                  image: 'redis:3.2',
                  ports: [
                    {
                      name: 'redis-port',
                      containerPort: 6379,
                      hostPort: 6379
                    }
                  ],
                  volumeMounts: [
                    {
                      name: 'mydb',
                      mountPath: '/data/db'
                    }
                  ]
                }
              ],
              volumes: [
                {
                  name: 'mydb',
                  persistentVolumeClaim: {
                    claimName: 'mydb'
                  }
                }
              ]
            }
          }
        }
      }
    end

    before do
      allow_any_instance_of(described_class).to receive(:system).and_return(true)
    end

    it 'creates a replication controller' do
      expect_any_instance_of(described_class).to receive(:system)
        .with("echo '#{manifest.to_json}' | "\
               'kubectl create -f - --namespace=staging')

      subject
    end

    context 'when an error happens during the replication controller creation' do
      before do
        allow_any_instance_of(described_class).to receive(:system).and_return(false)
      end

      it 'raises a ReplicationControllerCreationError' do
        expect { subject }
          .to raise_error(
            Databases::ReplicationControllerCreator::ReplicationControllerCreationError
          )
      end
    end
  end
end
