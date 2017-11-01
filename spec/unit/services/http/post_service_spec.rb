require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Http::PostService do
  subject { described_class.call({ message_key: 'message' }, 'http://some_hook_url') }

  before do
    WebMock.stub_request(:post, 'http://some_hook_url')
           .to_return(status: 200, body: '', headers: {})
  end

  it 'send a JSON POST request to the provided URL' do
    subject

    expect(WebMock).to have_requested(:post, 'http://some_hook_url')
      .with(
        body: WebMock::Util::QueryMapper.values_to_query(message_key: 'message')
      ).once
  end

  it 'returns true' do
    expect(subject).to eq(true)
  end

  context 'when the connection fails' do
    before do
      WebMock.stub_request(:post, 'http://some_hook_url').to_raise(Errno::ECONNREFUSED.new)
    end

    it 'returns false' do
      expect(subject).to eq(false)
    end
  end
end
