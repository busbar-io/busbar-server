require 'spec_helper'

RSpec.describe SettingsController, type: :request do
  let(:some_app) do
    App.create(
      _id: 'some_app',
      buildpack_id: 'ruby',
      repository: 'git@example.com:EXAMPLE/app.git'
    )
  end

  let(:environment) do
    Environment.create(
      _id: 'staging',
      app_id: some_app.id,
      name: 'staging',
      buildpack_id: 'ruby',
      settings: settings
    )
  end

  let(:settings) { {} }

  after do
    App.where(_id: 'some_app').destroy_all
    environment.destroy!
  end

  describe 'GET apps/:app_id/environments/:environment_id/settings' do
    before do
      get "/apps/#{some_app.id}/environments/#{environment.name}/settings.json"
    end

    let(:settings) do
      {
        PUBLIC_URL: 'http://app.public.url',
        MONGODB: 'mongodb://app_mongo'
      }
    end

    it 'returns the settings of the environment' do
      expect(JSON.parse(response.body)).to match({
        data: [
          {
            key: 'PUBLIC_URL',
            value: 'http://app.public.url'
          },
          {
            key: 'MONGODB',
            value: 'mongodb://app_mongo'
          }
        ]
      }.with_indifferent_access)
    end

    it 'responds with HTTP 200 OK' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET apps/:app_id/settings/:id' do
    let(:settings) do
      {
        PUBLIC_URL: 'http://app.public.url',
        MONGODB: 'mongodb://app_mongo'
      }
    end

    context 'when the setting exists' do
      before do
        get "/apps/#{some_app.id}/environments/#{environment.name}/settings/PUBLIC_URL.json"
      end

      it 'returns the requested setting of the environment' do
        expect(JSON.parse(response.body)).to match({
          data: {
            key: 'PUBLIC_URL',
            value: 'http://app.public.url'
          }
        }.with_indifferent_access)
      end

      it 'responds with HTTP 200 OK' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the setting does not exist' do
      before do
        get "/apps/#{some_app.id}/environments/#{environment.name}/settings/UNKNOWN_SETTING.json"
      end

      it 'returns an empty response' do
        expect(response.body).to be_empty
      end

      it 'responds with HTTP 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'PUT apps/:app_id/settings/:id' do
    context 'when sending a valid update request' do
      before do
        put(
          "/apps/#{some_app.id}/environments/#{environment.name}/settings/some_setting",
          { value: 'new_value' },
          'Accept' => 'application/json'
        )
      end

      context 'with a brand new setting as param' do
        it 'responds with HTTP 200 OK' do
          expect(response).to have_http_status(200)
        end

        it 'creates the setting and returns a JSON containing the  setting and value' do
          expect(JSON.parse(response.body)).to eq(
            'data' => { 'key' => 'some_setting', 'value' => 'new_value' }
          )
        end
      end

      context 'with an existing setting as param' do
        let(:settings) do
          { some_setting: 'original_value' }
        end

        it 'responds with HTTP 200 OK' do
          expect(response).to have_http_status(200)
        end

        it 'updates the setting and returns a JSON containing the updated setting and value' do
          expect(JSON.parse(response.body)).to eq(
            'data' => { 'key' => 'some_setting', 'value' => 'new_value' }
          )
        end
      end
    end

    context 'when sending an invalid update request' do
      before do
        put(
          "/apps/#{some_app.id}/environments/#{environment.name}/settings/some_setting",
          { value: nil },
          'Accept' => 'application/json'
        )
      end

      it 'responds with HTTP 422' do
        expect(response).to have_http_status(422)
      end

      it 'informs that value can not be blank' do
        expect(JSON.parse(response.body)).to eq(
          'errors' => ["Value can't be blank"]
        )
      end
    end
  end

  describe 'DELETE apps/:app_id/environments/:environment_name/:settings/:id' do
    let(:settings) do
      {
        PUBLIC_URL: 'http://app.public.url',
        MONGODB: 'mongodb://app_mongo'
      }
    end

    context 'when the setting exists' do
      before do
        delete(
          "/apps/#{some_app.id}/environments/#{environment.name}/settings/PUBLIC_URL",
          {},
          'Accept' => 'application/json'
        )
      end

      it 'responds with HTTP 204' do
        expect(response).to have_http_status(204)
      end

      it 'removes the setting from the environment' do
        expect(Environment.find(environment.id).settings)
          .to_not include(PUBLIC_URL: 'http://app.public.url')
      end
    end

    context 'when the setting does not exist' do
      before do
        delete(
          "/apps/#{some_app.id}/environments/#{environment.name}/settings/UNKNOWN_SETTING",
          {},
          'Accept' => 'application/json'
        )
      end

      it 'responds with HTTP 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns an empty response' do
        expect(response.body).to be_empty
      end
    end
  end
end
