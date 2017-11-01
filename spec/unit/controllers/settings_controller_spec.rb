require 'spec_helper'

RSpec.describe SettingsController, type: :controller do
  render_views

  describe 'DELETE /apps/:app_id/environments/:environment_name/settings/SOME_SETTING' do
    let(:response) do
      delete :destroy,
             app_id: some_app.id,
             environment_name: environment.name,
             id: 'SOME_SETTING',
             format: :json
    end

    let!(:some_app) do
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
        settings: {
          'SOME_SETTING': 'some_value',
          'REDIS_URL': 'redis://test'
        }
      )
    end

    before do
      allow(SettingService).to receive(:find)
        .and_return(setting)
    end

    let(:setting) { Setting.new(key: 'SOME_SETTING', value: 'some_value') }

    context 'when the deletion succeeds' do
      before do
        allow(SettingService).to receive(:destroy)
          .with(environment, setting)
          .and_return(true)
      end

      it 'responds with HTTP 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the deletion fails' do
      before do
        allow(SettingService).to receive(:destroy)
          .with(environment, setting)
          .and_return(false)
      end

      it 'responds with HTTP 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns an empty body' do
        expect(JSON.parse(response.body)).to eq({})
      end
    end
  end
end
