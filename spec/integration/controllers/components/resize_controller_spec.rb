require 'spec_helper'

RSpec.describe Components::ResizeController, type: :request do
  describe 'PUT /apps/:app_id/environment/:environment_id/components/:component_type/resize' do
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

    subject do
      put(
        "/apps/#{some_app.id}/environments/#{environment.name}/components/#{component.type}/resize",
        { node_id: '4x.standard', format: :json },
        'Accept' => 'application/json'
      )
    end

    it 'returns HTTP status 202' do
      subject

      expect(response).to have_http_status(202)
    end

    it 'returns an empty string' do
      subject
      expect(response.body).to eq('')
    end

    it 'schedules a job to resize the component' do
      expect { subject }.to change(Components::ResizeProcessing.jobs, :size).by(1)
    end

    it 'schedules a ResizeProcessing job to the default queue' do
      subject

      expect(Sidekiq::Queues['default'].last['class']).to match('Components::ResizeProcessing')
    end

    it 'schedules the resizing of the given component' do
      subject

      expect(Sidekiq::Queues['default'].last['args'])
        .to match_array(['4x.standard', 'web'])
    end

    context 'when the param node_id is not present' do
      subject do
        put(
          "/apps/#{some_app.id}/environments/#{environment.name}/" \
          "components/#{component.type}/resize",
          { format: :json },
          'Accept' => 'application/json'
        )
      end

      it 'returns status 422' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context "when there's no Node with the provided id" do
      subject do
        put(
          "/apps/#{some_app.id}/environments/#{environment.name}/" \
          "components/#{component.type}/resize",
          { node_id: 'some_node_that_does_not_exist', format: :json },
          'Accept' => 'application/json'
        )
      end

      it 'returns status 422' do
        subject

        expect(response).to have_http_status(422)
      end
    end
  end
end
