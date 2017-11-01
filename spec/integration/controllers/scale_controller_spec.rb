require 'spec_helper'

RSpec.describe ScaleController, type: :request do
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

  let!(:component) do
    Component.create(
      id: 'web',
      environment_id: environment.id,
      command: 'a command',
      type: 'web',
      scale: 1,
      image_url: 'a image'
    )
  end

  after do
    some_app.destroy!
    environment.destroy!
    component.destroy!
  end

  describe 'GET /apps/:app_id/environments/:environment_name/components/:component_type/scale' do
    before do
      get "/apps/#{some_app.id}/environments/"\
          "#{environment.name}/components/#{component.type}/scale.json"
    end

    it 'returns HTTP status 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns the component' do
      expect(JSON.parse(response.body)).to match({
        scale: 1
      }.with_indifferent_access)
    end
  end

  describe 'PUT /apps/:app_id/environments/:environment_name/components/:component_id/scale' do
    let(:request) do
      put(
        "/apps/#{some_app.id}/environments/#{environment.name}/components/#{component.type}/scale",
        {
          scale: 10
        },
        'Accept' => 'application/json'
      )
    end

    it 'returns HTTP status 202' do
      request

      expect(response).to have_http_status(202)
    end

    it 'schedules a job to scale the component' do
      expect { request }.to change(ScaleProcessing.jobs, :size).by(1)
    end

    it 'schedules a ScaleProcessing job to the default queue' do
      request

      expect(Sidekiq::Queues['default'].last['class']).to match('ScaleProcessing')
    end

    it 'schedules the scaling of the given component to the given size' do
      request

      expect(Sidekiq::Queues['default'].last['args']).to match_array(%w(web 10))
    end
  end
end
