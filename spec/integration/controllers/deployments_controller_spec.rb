require 'spec_helper'

RSpec.describe DeploymentsController, type: :request do
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

    environment.deployments.destroy

    environment.destroy
  end

  describe 'POST /apps/:app_id/environments/:environment_name/deployments/' do
    context 'with no branch nor build_pack_id' do
      let(:request) do
        post(
          "/apps/#{some_app.id}/environments/#{environment.name}/deployments",
          {},
          'Accept' => 'application/json'
        )
      end

      let(:deployment_attributes) do
        {
          id: environment.deployments.last.id,
          branch: environment.default_branch,
          buildpack_id: 'ruby',
          created_at: Time.zone.now,
          updated_at: Time.zone.now,
          state: 'pending'
        }
      end

      it 'creates the deployment' do
        expect { request }.to change(Deployment, :count).by(1)
      end

      it 'creates the deployment with the default values' do
        request

        expect(environment.deployments.last)
          .to have_attributes(deployment_attributes)
      end

      it 'returns a deployment with the default values' do
        request

        expect(JSON.parse(response.body)).to match(
          {
            data: deployment_attributes
          }.with_indifferent_access
        )
      end

      it 'returns HTTP status 201' do
        request

        expect(response).to have_http_status(201)
      end

      it 'schedules a job to deploy the environment' do
        expect { request }.to change(DeploymentProcessing.jobs, :size).by(1)
      end

      it 'schedules a DeploymentProcessing job to the default queue' do
        request

        expect(Sidekiq::Queues['default'].last['class']).to match('DeploymentProcessing')
      end

      it 'schedules the processing of the new deployment' do
        request

        expect(Sidekiq::Queues['default'].last['args'])
          .to match_array([deployment_attributes[:id], { 'notifiy' => true }])
      end
    end

    context 'with branch and/or build_pack_id' do
      let(:request) do
        post(
          "/apps/#{some_app.id}/environments/#{environment.name}/deployments",
          {
            buildpack_id: 'java',
            branch: 'develop'
          },
          'Accept' => 'application/json'
        )
      end

      let(:deployment_attributes) do
        {
          id: environment.deployments.last.id,
          branch: 'develop',
          buildpack_id: 'java',
          created_at: Time.zone.now,
          updated_at: Time.zone.now,
          state: 'pending'
        }
      end

      it 'creates the deployment' do
        expect { request }.to change(Deployment, :count).by(1)
      end

      it 'creates the deployment with the provided data' do
        request

        expect(environment.deployments.last)
          .to have_attributes(deployment_attributes)
      end

      it 'returns a deployment with those values setted' do
        request

        expect(JSON.parse(response.body)).to match(
          {
            data: deployment_attributes
          }.with_indifferent_access
        )
      end

      it 'returns HTTP status 201' do
        request

        expect(response).to have_http_status(201)
      end

      it 'schedules a job to deploy the environment' do
        expect { request }.to change(DeploymentProcessing.jobs, :size).by(1)
      end

      it 'schedules a DeploymentProcessing job to the default queue' do
        request

        expect(Sidekiq::Queues['default'].last['class']).to match('DeploymentProcessing')
      end

      it 'schedules the processing of the new deployment' do
        request

        expect(Sidekiq::Queues['default'].last['args'])
          .to match_array([deployment_attributes[:id], { 'notifiy' => true }])
      end
    end
  end
end
