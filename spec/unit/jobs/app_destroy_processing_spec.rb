require 'rails_helper'
require 'webmock/rspec'

RSpec.describe AppDestroyProcessing do
  describe '.perform' do
    subject { described_class.new.perform(app_id) }

    before do
      allow(EnvironmentService).to receive(:destroy)
      allow(HookService).to receive(:call)
    end

    context 'when the given app exists' do
      let(:app_id) { some_app.id }

      before do
        allow(App).to receive(:find).and_return(some_app)
        allow(some_app).to receive(:environments).and_return([environment])
      end

      let(:some_app) do
        App.new(
          _id: 'some_app',
          buildpack_id: 'ruby',
          repository: 'git@example.com:EXAMPLE/app.git'
        )
      end

      let(:environment) do
        Environment.new(
          _id: 'staging',
          app_id: some_app.id,
          buildpack_id: 'ruby',
          settings: {
            'MONGO_URL': 'mongodb://test',
            'REDIS_URL': 'redis://test'
          }
        )
      end

      it "destroys the app's environments" do
        subject

        expect(EnvironmentService).to have_received(:destroy).with(environment).once
      end

      it 'creates a notification about the app destruction' do
        expect(HookService).to receive(:call)
          .with(resource: some_app, action: 'destroy', value: 'success')

        subject
      end
    end

    context 'when the given app is nil' do
      let(:app_id) { nil }

      it 'returns false' do
        expect { subject }
          .to raise_error(AppDestroyProcessing::AppNotFound)
      end

      it 'does not create a notification about the app destruction' do
        begin
          subject
        rescue AppDestroyProcessing::AppNotFound
          expect(HookService).to_not have_received(:call)
        end
      end
    end

    context 'when the given app does not exist' do
      let(:app_id) { 'some_app_that_does_not_exist' }

      it 'returns false' do
        expect { subject }
          .to raise_error(AppDestroyProcessing::AppNotFound)
      end

      it 'does not create a notification about the app destruction success' do
        begin
          subject
        rescue AppDestroyProcessing::AppNotFound
          expect(HookService).to_not receive(:call)
        end
      end
    end
  end
end
