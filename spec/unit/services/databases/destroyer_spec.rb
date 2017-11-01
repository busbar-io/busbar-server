require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Databases::Destroyer do
  describe '.call' do
    subject { described_class.call(database) }

    before do
      allow(DatabaseDestroyProcessing).to receive(:perform_async)
    end

    context "when the given app exists and it's not nil" do
      let(:database) { instance_double(Database, id: 'mydb') }

      it 'processes the database destruction' do
        expect(DatabaseDestroyProcessing).to receive(:perform_async).with('mydb')

        subject
      end
    end

    context 'when the given database is nil' do
      let(:database) { nil }

      it 'returns false' do
        expect(subject).to eq(false)
      end

      it 'does not process the database destruction' do
        expect(DatabaseDestroyProcessing).to_not receive(:perform_async)

        subject
      end
    end
  end
end
