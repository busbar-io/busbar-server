require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Apps::Destroyer do
  describe '.call' do
    subject { described_class.call(some_app) }

    context "when the given app exists and it's not nil" do
      let!(:some_app) do
        App.create(
          _id: 'some_app',
          buildpack_id: 'ruby',
          repository: 'git@example.com:EXAMPLE/app.git'
        )
      end

      after do
        some_app.destroy!
      end

      before do
        allow(AppDestroyProcessing).to receive(:perform_async)
      end

      it 'processes the app deletion' do
        subject

        expect(AppDestroyProcessing).to have_received(:perform_async).with(some_app.id)
      end
    end

    context 'when the given app is nil' do
      let(:some_app) { nil }

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end
end
