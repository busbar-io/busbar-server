require 'spec_helper'

RSpec.describe AppsController, type: :request do
  let!(:some_app) do
    App.create(
      _id: 'some_app',
      buildpack_id: 'ruby',
      repository: 'git@example.com:EXAMPLE/app.git'
    )
  end

  let!(:environment) do
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

  def as_hash(some_app)
    {
      id: some_app.id,
      buildpack_id: some_app.buildpack_id,
      repository: some_app.repository,
      environments: some_app.environments.pluck(:name),
      created_at: some_app.created_at.iso8601,
      updated_at: some_app.updated_at.iso8601,
      default_branch: some_app.default_branch
    }
  end

  describe 'GET /apps/' do
    before do
      get '/apps.json'
    end

    it 'renders the apps as a json' do
      expect(JSON.parse(response.body)).to match({
        data: App.all.map do |app|
          as_hash(app)
        end
      }.with_indifferent_access)
    end

    it 'returns HTTP status 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /app/:id' do
    before do
      get "/apps/#{some_app.id}.json"
    end

    it 'renders the app as a json' do
      expect(JSON.parse(response.body)).to match({
        data:
          as_hash(some_app)
      }.with_indifferent_access)
    end

    it 'returns HTTP status 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /apps/' do
    context 'with no default_branch' do
      let(:app_params) do
        {
          'id' => 'new_app',
          'repository' => 'git:new_app_id_repository'
        }
      end
      let(:request)  do
        post(
          '/apps',
          app_params,
          'Accept' => 'application/json'
        )
      end

      it 'returns HTTP status 201' do
        request

        expect(response).to have_http_status(202)
      end

      it 'schedules a job to create the app' do
        expect { request }.to change(AppProcessing.jobs, :size).by(1)
      end

      it 'schedules an AppProcessing job to the default queue' do
        request

        expect(Sidekiq::Queues['default'].last['class']).to match('AppProcessing')
      end

      it 'schedules the app process with the given attributes' do
        request

        expect(Sidekiq::Queues['default'].last['args']).to match_array([app_params, {}, {}])
      end
    end

    context 'with a default_env' do
      let(:app_params) do
        {
          'id' => 'new_app',
          'repository' => 'git:new_app_id_repository'
        }
      end
      let(:options_params) { { 'default_env' => 'staging' } }
      let(:request)  do
        post(
          '/apps',
          app_params.merge(options_params),
          'Accept' => 'application/json'
        )
      end

      it 'schedules the app process with the given attributes' do
        request

        expect(Sidekiq::Queues['default'].last['args']).to \
          match_array([app_params, options_params, {}])
      end
    end

    context 'with environment attributes' do
      let(:app_params) do
        {
          'id' => 'new_app',
          'repository' => 'git:new_app_id_repository',
          'default_branch' => 'develop'
        }
      end

      let(:environment_params) do
        {
          'environment' => {
            'id' => 'new_env',
            'name' => 'staging',
            'buildpack_id' => 'ruby',
            'public' => 'false',
            'default_branch' => 'develop',
            'default_node_id' => '123',
            'settings' => {
              'MONGO_URL' => 'mongodb://test',
              'REDIS_URL' => 'redis://test'
            }
          }
        }
      end
      let(:request)  do
        post(
          '/apps',
          app_params.merge(environment_params),
          'Accept' => 'application/json'
        )
      end

      it 'schedules the app process with the given attributes' do
        request

        expect(Sidekiq::Queues['default'].last['args']).to \
          match_array([app_params, {}, environment_params])
      end
    end
  end

  describe 'PUT /apps/:id' do
    let(:request)  do
      put(
        "/apps/#{some_app.id}",
        {
          repository: 'git@example.com:EXAMPLE/new_repo.git',
          format: :json
        },
        'Accept' => 'application/json'
      )
    end

    it 'updates only the provided attribute' do
      request

      expect(App.find('some_app')).to have_attributes(
        buildpack_id: 'ruby',
        repository: 'git@example.com:EXAMPLE/new_repo.git'
      )
    end

    it 'returns the app after updating' do
      request

      expect(JSON.parse(response.body)).to match(
        {
          data: as_hash(App.find('some_app'))
        }.with_indifferent_access
      )
    end

    it 'returns HTTP status 200' do
      request

      expect(response).to have_http_status(200)
    end

    context 'with params that break the model validation' do
      let(:request)  do
        put(
          "/apps/#{some_app.id}",
          {
            repository: nil,
            format: :json
          },
          'Accept' => 'application/json'
        )
      end

      it 'returns HTTP status 422' do
        request

        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE /apps/:id' do
    let(:request)  do
      delete(
        "/apps/#{some_app.id}",
        {},
        'Accept' => 'application/json'
      )
    end

    it 'returns an empty response body' do
      request

      expect(response.body).to be_empty
    end

    it 'returns HTTP status 204' do
      request

      expect(response).to have_http_status(204)
    end

    it 'schedules a job to destroy the app' do
      expect { request }.to change(AppDestroyProcessing.jobs, :size).by(1)
    end

    it 'schedules a AppDestroyProcessing job to the default queue' do
      request

      expect(Sidekiq::Queues['default'].last['class']).to match('AppDestroyProcessing')
    end

    it 'schedules the destruction of the given app' do
      request

      expect(Sidekiq::Queues['default'].last['args']).to match_array([some_app.id])
    end
  end
end
