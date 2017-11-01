require 'spec_helper'

RSpec.describe EnvironmentCloneController, type: :request do
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
        'MONGO_URL': 'mongodb://test',
        'REDIS_URL': 'redis://test'
      }
    )
  end

  after do
    some_app.destroy!
    environment.destroy!
  end

  describe 'POST /apps/:app_id/environments/:environment_name/clone' do
    let(:request) do
      post(
        "/apps/#{some_app.id}/environments/#{environment.name}/clone",
        {
          clone_name: 'my-clone-name'
        },
        'Accept' => 'application/json'
      )
    end

    it 'returns HTTP status 202' do
      request

      expect(response).to have_http_status(202)
    end

    it 'schedules a job to scale the component' do
      expect { request }.to change(EnvironmentCloneProcessing.jobs, :size).by(1)
    end

    it 'schedules a EnvironmentCloneProcessing job to the default queue' do
      request

      expect(Sidekiq::Queues['default'].last['class']).to match('EnvironmentCloneProcessing')
    end

    it 'schedules the cloning of the given environment' do
      request

      expect(Sidekiq::Queues['default'].last['args']).to match_array(%w(staging my-clone-name))
    end
  end
end
