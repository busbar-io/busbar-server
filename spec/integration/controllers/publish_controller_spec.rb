require 'spec_helper'

RSpec.describe PublishController, type: :request do
  describe 'PUT /apps/:app_id/environment/:environment_name/publish' do
    let(:some_app) do
      App.create(
        _id: 'some_app',
        buildpack_id: 'ruby',
        repository: 'git@example.com:EXAMPLE/app.git'
      )
    end

    let(:environment) do
      Environment.create(
        _id: 'some_app-staging',
        app_id: some_app.id,
        name: 'staging',
        buildpack_id: 'ruby',
        settings: {
          'MONGO_URL': 'mongodb://test',
          'REDIS_URL': 'redis://test'
        }
      )
    end

    after do
      some_app.destroy!
      environment.destroy!
    end

    let(:request)  do
      put(
        "/apps/#{some_app.id}/environments/#{environment.name}/publish",
        {},
        'Accept' => 'application/json'
      )
    end

    it 'returns HTTP status 202' do
      request

      expect(response).to have_http_status(202)
    end

    it 'schedules a job to publish the app' do
      expect { request }.to change(PublishProcessing.jobs, :size).by(1)
    end

    it 'schedules a PublishProcessing job to the default queue' do
      request

      expect(Sidekiq::Queues['default'].last['class']).to match('PublishProcessing')
    end

    it 'schedules the publishing of the given app' do
      request

      expect(Sidekiq::Queues['default'].last['args']).to match_array(['some_app-staging'])
    end
  end
end
