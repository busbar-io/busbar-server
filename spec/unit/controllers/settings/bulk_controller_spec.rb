require 'spec_helper'

RSpec.describe Settings::BulkController, type: :controller do
  render_views

  describe 'PUT /apps/:app_id/environments/:environment_name/settings/bulk' do
    context 'when sending valid settings as params' do
      let(:response) do
        put :update,
            app_id: some_app.id,
            environment_name: some_environment.name,
            settings: settings_params,
            format: :json
      end

      before do
        allow(SettingService).to receive(:bulk_upsert).and_return(
          [
            Setting.new(key: 'PUBLIC_URL', value: 'www.example.com'),
            Setting.new(key: 'PRIVATE_URL', value: 'www.private-example.com'),
            Setting.new(key: 'MONGO_URL', value: 'mongodb://example-mongo')
          ]
        )

        allow(Environment).to receive(:find_by)
          .with(name: some_environment.name, app_id: some_app.id)
          .and_return(some_environment)
        allow(App).to receive(:find).with(some_app.id).and_return(some_app)
      end

      let(:settings_params) do
        {
          PUBLIC_URL: 'www.example.com',
          PRIVATE_URL: 'www.private-example.com',
          MONGO_URL: 'mongodb://example-mongo'
        }
      end

      let(:some_app) do
        App.new(
          _id: 'test-app',
          buildpack_id: 'ruby',
          repository: 'git@example.com:EXAMPLE/app.git'
        )
      end

      let(:some_environment) do
        Environment.new(
          _id: 'staging',
          app_id: some_app.id,
          name: 'staging',
          buildpack_id: 'ruby'
        )
      end

      after do
        some_app.destroy!
        some_environment.destroy!
      end

      it 'responds with HTTP 200 OK' do
        expect(response).to have_http_status(200)
      end

      it 'calls SettingService bulk_upsert with the given settings' do
        response

        expect(SettingService)
          .to have_received(:bulk_upsert)
          .with(some_environment, settings_params, deploy: true)
      end

      it 'returns a JSON containing the updated settings' do
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'PUBLIC_URL' => 'www.example.com',
            'PRIVATE_URL' => 'www.private-example.com',
            'MONGO_URL' => 'mongodb://example-mongo'
          }
        )
      end
    end
  end
end
