require 'rails_helper'

RSpec.describe Hooks::EnvironmentSerializer do
  subject { described_class.call(environment) }

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

  it 'serializes the environment' do
    expect(subject).to match(
      environment_app_id: 'some_app',
      environment_name: 'staging',
      environment_namespace: 'staging',
      environment_buildpack_id: 'ruby',
      environment_public: true,
      environment_state: 'new',
      environment_default_branch: 'staging',
      environment_default_node_id: '2x.standard',
      environment_repository: 'git@somerandomrepo.git'
    )
  end
end
