require 'rails_helper'

RSpec.describe Databases::Processor do
  describe '.call' do
    let(:database) { instance_double(Database, namespace: 'staging') }

    subject { described_class.call(database) }

    before do
      allow(NamespaceService).to receive(:upsert)
      allow(DatabaseService).to receive(:create_volume)
      allow(DatabaseService).to receive(:create_replication_controller)
      allow(DatabaseService).to receive(:create_service)
      allow(HookService).to receive(:call)
        .with(resource: database, action: 'create', value: 'success')
    end

    it 'upserts the database namespace' do
      expect(NamespaceService).to receive(:upsert).with('staging').once

      subject
    end

    it 'creates a volume for the database' do
      expect(DatabaseService).to receive(:create_volume).with(database).once

      subject
    end

    it 'creates a replication controller for the database' do
      expect(DatabaseService).to receive(:create_replication_controller).with(database).once

      subject
    end

    it 'creates a service for the database' do
      expect(DatabaseService).to receive(:create_service).with(database).once

      subject
    end

    it 'creates a notification about the database creation' do
      expect(HookService).to receive(:call)
        .with(resource: database, action: 'create', value: 'success').once

      subject
    end

    it 'returns the given database' do
      expect(subject).to eq(database)
    end
  end
end
