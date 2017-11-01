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

  let!(:first_build) do
    Build.create(
      environment_id: environment.id,
      buildpack_id: 'java',
      repository: environment.repository,
      branch: 'staging',
      created_at: Time.zone.now - 1.hour
    )
  end

  let!(:latest_build) do
    Build.create(
      environment_id: environment.id,
      buildpack_id: 'ruby',
      repository: environment.repository,
      branch: 'master',
      commit: '98eea65f1d4d8a2bda3953430d4f264d7c0b5106',
      tag: '0.14.0',
      created_at: Time.zone.now
    )
  end

  let!(:log) do
    Log.create(
      content: 'This is the log of the commands executed to build the environment',
      build: latest_build
    )
  end

  after do
    some_app.destroy!
    environment.destroy!
    latest_build.destroy!
    log.destroy!
  end

  describe 'GET /apps/:app_id/environments/:name/builds/latest' do
    before do
      get "/apps/#{some_app.id}/environments/#{environment.name}/builds/latest.json"
    end

    it 'renders the latest build as a json' do
      expect(JSON.parse(response.body)).to match({
        data: {
          id: latest_build.id.to_s,
          state: latest_build.state,
          buildpack_id: latest_build.buildpack_id,
          repository: latest_build.repository,
          branch: latest_build.branch,
          commit: latest_build.commit,
          tag: latest_build.tag,
          commands: latest_build.commands,
          built_at: latest_build.built_at,
          app_id: latest_build.app_id,
          environment_id: latest_build.environment.id.to_s,
          environment_name: latest_build.environment.name,
          created_at: latest_build.created_at.iso8601,
          updated_at: latest_build.updated_at.iso8601,
          log: latest_build.log_content
        }
      }.with_indifferent_access)
    end

    it 'returns HTTP status 200' do
      expect(response).to have_http_status(200)
    end
  end
end
