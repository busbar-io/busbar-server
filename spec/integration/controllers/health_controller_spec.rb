require 'spec_helper'

RSpec.describe HealthController, type: :request do
  describe 'GET /health' do
    before do
      get '/health'
    end

    it 'returns HTTP status 200' do
      expect(response).to have_http_status(200)
    end

    it "returns the text 'ok'" do
      expect(response.body).to eq('ok')
    end
  end
end
