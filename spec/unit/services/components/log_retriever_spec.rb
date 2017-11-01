require 'rails_helper'

RSpec.describe Components::LogRetriever do
  describe '.call' do
    subject { described_class.call(component, search_size) }

    before do
      allow(ElasticSearchClient).to receive(:search)
        .with(search_query)
        .and_return(search_result)

      allow(ComponentLog).to receive(:new)
        .with(content: content)
        .and_return(component_log)
    end

    let(:component) do
      instance_double(
        Component,
        app_id: 'some_app',
        type: 'web',
        environment_name: 'production'
      )
    end

    let(:component_log) { instance_double(ComponentLog, content: content) }
    let(:search_size) { 3 }

    let(:content) do
      "This is the first line of the log\n" \
      "This is the middle line of the log\n" \
      "This is the last line of the log\n"
    end

    let(:search_query) do
      {
        body: {
          query: {
            bool: {
              must: [
                {
                  match: { 'kubernetes.labels.busbar_io/app': 'some_app' }
                },
                {
                  match: { 'kubernetes.labels.busbar_io/component': 'web' }
                },
                {
                  match: { 'kubernetes.labels.busbar_io/environment': 'production' }
                }
              ]
            }
          },
          _source: ['log'],
          size: search_size,
          sort: [
            {
              '@timestamp': {
                'order': 'desc'
              }
            }
          ]
        }
      }
    end

    let(:search_result) do
      {
        'hits' => {
          'hits' => [
            {
              '_source' => {
                'log' => "This is the last line of the log\n"
              }
            },
            {
              '_source' => {
                'log' => "This is the middle line of the log\n"
              }
            },
            {
              '_source' => {
                'log' => "This is the first line of the log\n"
              }
            }
          ]
        }
      }
    end

    it 'returns a new log with the result of the search' do
      expect(subject).to eq(component_log)
    end

    context 'when the given size is nil' do
      subject { described_class.call(component, nil) }

      before do
        allow(Configurations).to receive_message_chain(:log, :components, :size)
          .and_return(search_size)
      end

      let(:search_size) { 2 }

      let(:content) do
        "This is the first line of the log\n" \
        "This is the last line of the log\n"
      end

      let(:search_result) do
        {
          'hits' => {
            'hits' => [
              {
                '_source' => {
                  'log' => "This is the last line of the log\n"
                }
              },
              {
                '_source' => {
                  'log' => "This is the first line of the log\n"
                }
              }
            ]
          }
        }
      end

      it 'uses the default config value when retrieving the logs' do
        expect(subject).to eq(component_log)
      end
    end
  end
end
