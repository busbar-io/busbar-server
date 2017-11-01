require 'rails_helper'

RSpec.describe HookService do
  subject do
    described_class.call(
      resource: resource,
      action: 'create',
      value: 'success',
      timestamp: Time.zone.now
    )
  end

  let(:resource) do
    double(
      :resource,
      name: 'name',
      attribute_1: 'value_1',
      attribute_2: 'value_2',
      class: double(:class, name: 'Resource')
    )
  end

  let(:hooks_url) { 'http://some_url_to_receive_hooks.com' }

  before do
    allow(Http::PostService).to receive(:call)

    allow(Configurations).to receive_message_chain(:hooks, :url).and_return(hooks_url)
    allow(Configurations).to receive_message_chain(:cluster, :name).and_return('cluster_name')

    class Hooks::ResourceSerializer
      def self.call(resource)
        {
          resource_name: resource.name,
          resource_attribute_1: resource.attribute_1,
          resource_attribute_2: resource.attribute_2
        }
      end
    end
  end

  context 'when there is a hooks url set' do
    let(:data) do
      {
        data: {
          cluster: 'cluster_name',
          resource_type: 'resource',
          resource: {
            resource_name: 'name',
            resource_attribute_1: 'value_1',
            resource_attribute_2: 'value_2'
          },
          action: 'create',
          info: 'success',
          timestamp: Time.zone.now.iso8601
        }
      }
    end

    it 'sends a notification to the hook endpoint with a proper message' do
      expect(Http::PostService).to receive(:call).with(data, hooks_url)

      subject
    end

    it 'logs the message sent' do
      allow(Http::PostService).to \
        receive(:call).with(data, hooks_url).and_return(true)

      expect(Rails.logger).to \
        receive(:info)
        .with({ service: 'hook_service', url: hooks_url, data: data, response: true }.to_json)

      subject
    end
  end

  context 'when there is no hooks url set' do
    let(:hooks_url) { nil }

    it 'does not send a notification to the hook endpoint' do
      expect(Http::PostService).to_not receive(:call)

      subject
    end
  end

  context 'when the serializer of the given resource is not implemented' do
    let(:resource) do
      double(
        :resource,
        class: double(:class, name: 'NonSerializedResource')
      )
    end

    it 'raises an error' do
      expect { subject }.to raise_error(NameError)
    end
  end
end
