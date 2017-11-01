require 'spec_helper'

RSpec.describe DatabasesController, type: :request do
  let!(:some_database) do
    Database.create(
      id: 'mydb',
      type: 'mongo',
      namespace: 'develop'
    )
  end

  after do
    some_database.destroy!
  end

  def as_hash(database)
    {
      id: database.id,
      type: database.type,
      namespace: database.namespace,
      size: "#{database.size}Gb",
      url: database.url,
      created_at: database.created_at.iso8601,
      updated_at: database.updated_at.iso8601
    }
  end

  describe 'GET /databases/' do
    before do
      get '/databases.json'
    end

    it 'renders the databases as a json' do
      expect(JSON.parse(response.body)).to match({
        data: Database.all.map do |database|
          as_hash(database)
        end
      }.with_indifferent_access)
    end

    it 'returns HTTP status 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /database/:id' do
    before do
      get "/databases/#{some_database.id}.json"
    end

    it 'renders the database as a json' do
      expect(JSON.parse(response.body)).to match({
        data:
          as_hash(some_database)
      }.with_indifferent_access)
    end

    it 'returns HTTP status 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /databases/' do
    context 'with valid params' do
      let(:request)  do
        post(
          '/databases',
          {
            id: 'newdb',
            type: 'mongo',
            namespace: 'develop'
          },
          'Accept' => 'application/json'
        )
      end

      after do
        Database.find('newdb').destroy!
      end

      it 'creates a database' do
        expect { request }.to change(Database, :count).by(1)
      end

      it 'creates the database with the provided data' do
        request

        expect(Database.find('newdb'))
          .to have_attributes(
            id: 'newdb',
            type: 'mongo',
            namespace: 'develop',
            size: 1
          )
      end

      it 'returns the database after creating' do
        request

        expect(JSON.parse(response.body)).to match(
          {
            data: {
              id: 'newdb',
              type: 'mongo',
              namespace: 'develop',
              size: '1Gb',
              url: 'mongo://newdb',
              created_at: Time.zone.now.iso8601,
              updated_at: Time.zone.now.iso8601
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
          '/databases',
          {
            id: 'newdb',
            type: nil
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

  describe 'DELETE /databases/:id' do
    let(:request)  do
      delete(
        "/databases/#{some_database.id}",
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
      expect { request }.to change(DatabaseDestroyProcessing.jobs, :size).by(1)
    end

    it 'schedules a DatabaseDestroyProcessing job to the default queue' do
      request

      expect(Sidekiq::Queues['default'].last['class']).to match('DatabaseDestroyProcessing')
    end

    it 'schedules the destruction of the given database' do
      request

      expect(Sidekiq::Queues['default'].last['args']).to match_array([some_database.id])
    end
  end
end
