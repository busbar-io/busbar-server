require 'spec_helper'

RSpec.describe DeploymentsController, type: :controller do
  render_views

  describe 'POST /apps/:app_id/environments/:environment_name/deployments/' do
    context 'with no branch nor build_pack_id' do
      let(:response) do
        post :create,
             {
               app_id: some_app.id,
               environment_name: environment.name,
               format: :json
             }.merge(deployment_options).merge(deployment_params)
      end

      let(:deployment_params) { { branch: 'master', buildpack_id: 'ruby' } }

      let(:deployment_options) { { build: true, sync: true, notifiy: true } }

      let(:deployment) do
        double(:deployment,
               id: 'deployment_id',
               branch: 'master',
               buildpack_id: 'ruby',
               state: 'pending',
               created_at: Time.zone.now,
               updated_at: Time.zone.now,
               persisted?: persisted
              )
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
            'MONGO_URL': 'mongodb://test',
            'REDIS_URL': 'redis://test'
          }
        )
      end

      let(:persisted) { true }

      before do
        allow(DeploymentService).to receive(:create)
          .with(environment, deployment_params, deployment_options)
          .and_return(deployment)
      end

      context 'when it generates a valid deployment' do
        it 'returns status 201 created' do
          expect(response).to have_http_status(201)
        end

        it 'creates a deployment with the provided params and options' do
          expect(DeploymentService).to receive(:create)
            .with(environment, deployment_params, deployment_options).once

          response
        end

        it 'returns the deployment created' do
          expect(JSON.parse(response.body)).to eq(
            {
              data: {
                id: deployment.id,
                branch: deployment.branch,
                buildpack_id: deployment.buildpack_id,
                state: deployment.state,
                created_at: deployment.created_at.iso8601,
                updated_at: deployment.updated_at.iso8601
              }
            }.with_indifferent_access
          )
        end
      end

      context 'when it generates an invalid deployment' do
        before do
          allow(deployment).to receive_message_chain(:errors, :full_messages)
            .and_return(error_message)
        end

        let(:persisted) { false }
        let(:error_message) { 'some validation issue occurred' }

        it 'returns status 422 unprocessable entity' do
          expect(response).to have_http_status(422)
        end

        it 'returns the deployment errors' do
          expect(JSON.parse(response.body)).to eq(
            'errors' => error_message
          )
        end
      end
    end
  end
end
