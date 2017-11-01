require 'spec_helper'

RSpec.describe Settings::BulkController, type: :request do
  describe 'PUT /apps/:app_id/environments/:environment_name/settings/bulk' do
    before do
      put(
        "/apps/#{some_app.id}/environments/#{environment.id}/settings/bulk",
        { settings: settings_params },
        'Accept' => 'application/json'
      )
    end

    let(:some_app) do
      App.create(
        _id: 'test-app',
        buildpack_id: 'ruby',
        repository: 'git@example.com:EXAMPLE/app.git'
      )
    end

    let(:environment) do
      Environment.create(
        _id: 'develop',
        app_id: some_app.id,
        buildpack_id: 'ruby'
      )
    end

    after do
      some_app.destroy!
      environment.destroy!
    end

    context 'when sending valid settings as params' do
      let(:settings_params) do
        {
          PUBLIC_URL: 'www.example.com',
          PRIVATE_URL: 'www.private-example.com',
          MONGO_URL: 'mongodb://example-mongo'
        }
      end

      it 'responds with HTTP 200 OK' do
        expect(response).to have_http_status(200)
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

    context 'when sending an invalid setting as param' do
      let(:settings_params) do
        {
          PUBLIC_URL: 'www.example.com',
          PRIVATE_URL: nil,
          MONGO_URL: 'mongodb://example-mongo',
          some_other_setting: nil
        }
      end

      it 'responds with HTTP 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a JSON containing the updated settings' do
        expect(JSON.parse(response.body)).to eq(
          'data' => {
            'PUBLIC_URL' => 'www.example.com',
            'MONGO_URL' => 'mongodb://example-mongo'
          },
          'errors' => {
            'PRIVATE_URL' => {
              'value' => nil,
              'messages' => ["Value can't be blank"]
            },
            'some_other_setting' => {
              'value' => nil,
              'messages' => ["Value can't be blank"]
            }
          }
        )
      end
    end
  end
end
