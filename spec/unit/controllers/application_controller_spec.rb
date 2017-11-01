require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'rescue_from Mongoid::Errors::DocumentNotFound' do
    subject { request }

    controller do
      def index
        render text: 'index called'
      end

      def show
        raise Mongoid::Errors::DocumentNotFound.new Class.new, params
      end
    end

    context 'when call to the action succeeds' do
      let(:request) { get :index }

      it 'returns http status 200' do
        expect(subject).to have_http_status(200)
      end

      it 'renders the content of the action' do
        expect(subject.body).to eq('index called')
      end

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when call to the action raises Mongoid::Errors::DocumentNotFound' do
      let(:request) { get :show, id: 'some_id' }

      it 'returns 404' do
        expect(subject).to have_http_status(404)
      end

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end
    end
  end
end
