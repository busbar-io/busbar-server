require 'rails_helper'

RSpec.describe HookService do
  subject do
    described_class.call(
      resource: environment,
      action: 'created',
      value: 'success',
      timestamp: Time.zone.now
    )
  end

  let(:environment) do
    instance_double(
      Environment,
      app_id: 'some_app',
      name: 'staging',
      namespace: 'staging',
      buildpack_id: 'ruby',
      public: true,
      state: 'new',
      default_branch: 'staging',
      default_node_id: '2x.standard',
      repository: 'git@somerandomrepo.git',
      class: double(:class, name: 'Environment')
    )
  end

  let(:hooks_url) { 'http://some_url_to_receive_hooks.com' }

  before do
    allow(Configurations).to receive_message_chain(:hooks, :url).and_return(hooks_url)
    allow(Configurations).to receive_message_chain(:cluster, :name).and_return('cluster_name')
  end

  context 'when there is a hooks url set' do
    it 'sends a notification to the hook endpoint with a proper message' do
      expect(Http::PostService).to receive(:call)
        .with(
          {
            data: {
              resource_type: 'environment',
              cluster: 'cluster_name',
              resource: {
                environment_app_id: 'some_app',
                environment_name: 'staging',
                environment_namespace: 'staging',
                environment_buildpack_id: 'ruby',
                environment_public: true,
                environment_state: 'new',
                environment_default_branch: 'staging',
                environment_default_node_id: '2x.standard',
                environment_repository: 'git@somerandomrepo.git'
              },
              action: 'created',
              info: 'success',
              timestamp: Time.zone.now.iso8601
            }
          },
          hooks_url
        )

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
end
