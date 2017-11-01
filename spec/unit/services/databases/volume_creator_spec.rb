require 'rails_helper'

RSpec.describe Databases::VolumeCreator do
  describe '.call' do
    subject { described_class.call(database) }

    let(:database) do
      instance_double(
        Database,
        name: 'mydb',
        namespace: 'staging',
        size: 10
      )
    end

    let(:manifest) do
      {
        kind: 'PersistentVolumeClaim',
        apiVersion: 'v1',
        metadata: {
          name: 'mydb',
          annotations: {
            'volume.beta.kubernetes.io/storage-class' => 'standard'
          }
        },
        spec: {
          accessModes: ['ReadWriteOnce'],
          resources: {
            requests: {
              storage: '10Gi'
            }
          }
        }
      }
    end

    before do
      allow_any_instance_of(described_class).to receive(:system).and_return(true)
    end

    it 'creates a volume' do
      expect_any_instance_of(described_class).to receive(:system)
        .with("echo '#{manifest.to_json}' | "\
               'kubectl create -f - --namespace=staging')

      subject
    end

    context 'when an error happens during the volume creation' do
      before do
        allow_any_instance_of(described_class).to receive(:system).and_return(false)
      end

      it 'raises a VolumeCreationError' do
        expect { subject }
          .to raise_error(Databases::VolumeCreator::VolumeCreationError)
      end
    end
  end
end
