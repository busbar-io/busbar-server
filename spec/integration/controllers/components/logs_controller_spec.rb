require 'spec_helper'

RSpec.describe Components::LogsController, type: :request do
  describe 'GET /apps/:app_id/environment/:environment_id/components/:component_type/log' do
    let(:some_app) do
      App.create(
        _id: 'some_app',
        buildpack_id: 'ruby',
        repository: 'git@example.com:EXAMPLE/app.git'
      )
    end

    let(:environment) do
      Environment.create(
        _id: 'some_app-production',
        app_id: some_app.id,
        name: 'production',
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
      VCR.use_cassette('10_line_log') do
        get(
          "/apps/#{some_app.id}/environments/#{environment.name}/components/#{component.type}/log",
          { size: '10', format: :json },
          'Accept' => 'application/json'
        )
      end
    end

    it 'returns HTTP status 200' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns the last n lines of the log of the component' do
      subject
      expect(JSON.parse(response.body)).to match(
        'data' => {
          'content' => "This is the content of the log\n" \
                       "This is the content of the log\n" \
                       "This is the content of the log\n" \
                       "This is the content of the log\n" \
                       "This is the content of the log\n" \
                       "This is the content of the log\n" \
                       "This is the content of the log\n" \
                       "This is the content of the log\n" \
                       "This is the content of the log\n" \
                       "This is the content of the log\n"
        }
      )
    end

    context 'when the param size is not present' do
      subject do
        VCR.use_cassette('2_line_log') do
          get(
            "/apps/#{some_app.id}/environments/#{environment.name}/" \
            "components/#{component.type}/log",
            { format: :json },
            'Accept' => 'application/json'
          )
        end
      end

      before do
        allow(Configurations).to receive_message_chain(:log, :components, :size).and_return(2)
      end

      it 'returns status 200' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'returns the last default n lines of the log of the component' do
        subject
        expect(JSON.parse(response.body)).to match(
          'data' => {
            'content' => "This is the content of the log\n" \
                         "This is the content of the log\n"
          }
        )
      end
    end
  end
end
