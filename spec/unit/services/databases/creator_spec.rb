require 'rails_helper'

RSpec.describe Databases::Creator do
  describe '.call' do
    let(:data) { { id: 'test', type: 'mongo', namespace: 'develop' } }
    let(:database)  { Database.new(data) }

    subject { described_class.call(data) }

    before do
      allow(Database).to receive(:create).with(data).and_return(database)
      allow(database).to receive(:valid?).and_return(true)
      allow(DatabaseProcessing).to receive(:perform_async)
    end

    it 'creates the database' do
      expect(Database).to receive(:create).with(data)

      subject
    end

    it 'returns the created database' do
      expect(subject).to eq(database)
    end

    it 'processes the database' do
      expect(DatabaseProcessing).to receive(:perform_async).with(database.id).once

      subject
    end

    context 'when the created database is invalid' do
      before do
        allow(database).to receive(:valid?).and_return(false)
      end

      it 'returns the database' do
        expect(subject).to eq(database)
      end

      it 'does not process the database' do
        expect(DatabaseProcessing).to_not receive(:perform_async)

        subject
      end
    end
  end
end
