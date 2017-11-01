require 'rails_helper'
require 'webmock/rspec'

RSpec.describe DatabaseDestroyProcessing do
  describe '.perform' do
    subject { described_class.new.perform('mydb') }

    let(:database) do
      instance_double(Database, id: 'mydb', name: 'mydb', namespace: 'staging', destroy: true)
    end

    before do
      allow(Database).to receive(:find).with('mydb').and_return(database)

      allow(HookService).to receive(:call)
        .with(resource: database, action: 'destroy', value: 'success')

      allow(NamespaceService).to receive(:destroy).with('staging')

      allow_any_instance_of(described_class).to receive(:system)

      allow_any_instance_of(described_class).to receive(:sleep)
        .with(Configurations.databases.destruction_wait)
    end

    it 'destroys the database service' do
      expect_any_instance_of(described_class).to receive(:system)
        .with('kubectl delete service mydb --namespace=staging')
        .once

      subject
    end

    it 'destroys the database replication controller' do
      expect_any_instance_of(described_class).to receive(:system)
        .with('kubectl delete replicationcontroller mydb --namespace=staging')
        .once

      subject
    end

    it 'destroys the database volume' do
      expect_any_instance_of(described_class).to receive(:system)
        .with('kubectl delete persistentvolumeclaim mydb --namespace=staging')
        .once

      subject
    end

    it 'sleeps for the time stablished in the config before destroying the namespace' do
      expect_any_instance_of(described_class).to receive(:sleep)
        .with(Configurations.databases.destruction_wait)
        .once

      subject
    end

    it 'destroys the database namespace' do
      expect(NamespaceService).to receive(:destroy).with('staging').once

      subject
    end

    it 'destroys the database' do
      expect(database).to receive(:destroy).once

      subject
    end

    context 'when the DB does not exist' do
      before do
        allow(Database).to receive(:find)
          .with('mydb')
          .and_raise(Mongoid::Errors::DocumentNotFound.new(Database, 'mydb'))
      end

      it 'raises an error' do
        expect { subject }.to raise_error(DatabaseDestroyProcessing::DatabaseNotFound)
      end
    end
  end
end
