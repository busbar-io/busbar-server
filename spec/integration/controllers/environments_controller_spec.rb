require 'spec_helper'

RSpec.describe EnvironmentsController, type: :request do
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

  def as_hash(environment)
    {
      id: environment.id,
      name: environment.name,
      app_id: environment.app_id,
      public: environment.public,
      namespace: environment.namespace,
      state: environment.state,
      buildpack_id: environment.buildpack_id,
      created_at: environment.created_at.iso8601,
      updated_at: environment.updated_at.iso8601,
      default_branch: environment.default_branch,
      default_node_id: environment.default_node_id,
      settings: environment.settings
    }
  end

  describe 'GET /apps/:app_id/environments/' do
    before do
      get "/apps/#{some_app.id}/environments.json"
    end

    let!(:other_app) do
      App.create(
        _id: 'some_other_app_id',
        buildpack_id: 'ruby',
        repository: 'git@example.com:EXAMPLE/app.git'
      )
    end

    let!(:environment_from_other_app) do
      Environment.create(
        _id: 'staging',
        app_id: 'some_other_app_id',
        name: 'staging',
        buildpack_id: 'ruby',
        settings: {
          'MONGO_URL': 'mongodb://test',
          'REDIS_URL': 'redis://test'
        }
      )
    end

    after do
      other_app.destroy
      environment_from_other_app.destroy
    end

    it "renders the apps's environments as a json" do
      expect(JSON.parse(response.body)).to match({
        data: some_app.environments.all.map do |environment|
          as_hash(environment)
        end
      }.with_indifferent_access)
    end

    it 'returns HTTP status 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /apps/:app_id/environments/:name' do
    before do
      get "/apps/#{some_app.id}/environments/#{environment.name}.json"
    end

    it 'renders the environment as a json' do
      expect(JSON.parse(response.body)).to match({
        data:
          as_hash(environment)
      }.with_indifferent_access)
    end

    it 'returns HTTP status 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /apps/:app_id/environments/' do
    context 'with setting params' do
      let(:request)  do
        post(
          "/apps/#{some_app.id}/environments",
          {
            id: 'new_environment',
            name: 'production',
            buildpack_id: 'ruby',
            settings: {
              MONGO_URL: 'mongodb://test',
              REDIS_URL: 'redis://test'
            }
          },
          'Accept' => 'application/json'
        )
      end

      after do
        Environment.find('new_environment').destroy!
      end

      it 'creates an environment' do
        expect { request }.to change(Environment, :count).by(1)
      end

      it 'creates the environment with the provided data' do
        request

        expect(Environment.find('new_environment'))
          .to have_attributes(
            id: 'new_environment',
            name: 'production',
            state: 'new',
            public: false,
            app_id: some_app.id,
            namespace: 'production',
            buildpack_id: 'ruby',
            default_branch: 'master',
            default_node_id: '1x.standard',
            created_at: Time.zone.now,
            updated_at: Time.zone.now,
            settings: {
              'MONGO_URL' => 'mongodb://test',
              'REDIS_URL' => 'redis://test'
            }
          )
      end
    end

    context 'with valid params' do
      let(:request)  do
        post(
          "/apps/#{some_app.id}/environments",
          {
            id: 'new_environment',
            name: 'production',
            buildpack_id: 'ruby'
          },
          'Accept' => 'application/json'
        )
      end

      after do
        Environment.find('new_environment').destroy!
      end

      it 'creates an environment' do
        expect { request }.to change(Environment, :count).by(1)
      end

      it 'creates the environment with the provided data' do
        request

        expect(Environment.find('new_environment'))
          .to have_attributes(
            id: 'new_environment',
            name: 'production',
            state: 'new',
            public: false,
            app_id: some_app.id,
            namespace: 'production',
            buildpack_id: 'ruby',
            default_branch: 'master',
            default_node_id: '1x.standard',
            created_at: Time.zone.now,
            updated_at: Time.zone.now,
            settings: {}
          )
      end

      it 'returns the environment after creating' do
        request

        expect(JSON.parse(response.body)).to match(
          {
            data: {
              id: 'new_environment',
              name: 'production',
              state: 'new',
              public: false,
              app_id: some_app.id,
              namespace: 'production',
              buildpack_id: 'ruby',
              default_branch: 'master',
              default_node_id: '1x.standard',
              created_at: Time.zone.now.iso8601,
              updated_at: Time.zone.now.iso8601,
              settings: {}
            }
          }.with_indifferent_access
        )
      end

      it 'returns HTTP status 201' do
        request

        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid params' do
      let(:request)  do
        post(
          "/apps/#{some_app.id}/environments",
          {
            id: 'new_environment',
            buildpack_id: nil
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

  describe 'PUT /apps/:app_id/environments/:name' do
    let(:request)  do
      put(
        "/apps/#{some_app.id}/environments/#{environment.name}",
        {
          buildpack_id: 'java',
          format: :json
        },
        'Accept' => 'application/json'
      )
    end

    it 'updates only the provided attribute' do
      request

      expect(Environment.find(environment.id)).to have_attributes(
        buildpack_id: 'java'
      )
    end

    it 'returns the environment after updating' do
      request

      expect(JSON.parse(response.body)).to match(
        {
          data: as_hash(Environment.find(environment.id))
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
          "/apps/#{some_app.id}/environments/#{environment.id}",
          {
            buildpack_id: nil,
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

  describe 'DELETE /apps/:app_id/environments/:name' do
    let(:request)  do
      delete(
        "/apps/#{some_app.id}/environments/#{environment.name}",
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

    it 'schedules a job to destroy the environment' do
      expect { request }.to change(EnvironmentDestroyProcessing.jobs, :size).by(1)
    end

    it 'schedules a EnvironmentDestroyProcessing job to the default queue' do
      request

      expect(Sidekiq::Queues['default'].last['class']).to match('EnvironmentDestroyProcessing')
    end

    it 'schedules the destruction of the given environment' do
      request

      expect(Sidekiq::Queues['default'].last['args']).to match_array([environment.id])
    end
  end
end
