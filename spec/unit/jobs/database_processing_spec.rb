require 'rails_helper'

RSpec.describe DatabaseProcessing do
  describe '#perform' do
    let(:database) { instance_double(Database, id: 'mydb') }

    subject { described_class.new.perform('mydb') }

    before do
      allow(Database).to receive(:find).with('mydb').and_return(database)
      allow(LockService).to receive(:synchronize).and_yield
      allow(DatabaseService).to receive(:process)
    end

    it 'processes the given database' do
      expect(DatabaseService).to receive(:process).with(database).once

      subject
    end

    it 'locks the database' do
      expect(LockService).to receive(:synchronize).with(database_id: 'mydb').and_yield

      subject
    end

    context 'when the Database does not exist' do
      let(:error) { Mongoid::Errors::DocumentNotFound.new(Database, ['mydb']) }

      before do
        allow(Database).to receive(:find).with('mydb').and_raise(error)
      end

      it 'raises the error DatabaseNotFound' do
        expect { subject }.to raise_error(DatabaseProcessing::DatabaseNotFound)
      end
    end
  end
end
