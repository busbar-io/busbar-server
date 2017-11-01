require 'rails_helper'

RSpec.describe Hooks::DeploymentSerializer do
  subject { described_class.call(deployment) }

  let(:deployment) do
    instance_double(
      Deployment,
      app_id: 'some_app',
      id: 'some_deployment_id',
      branch: 'master',
      state: 'ready',
      deployed_at: Time.zone.now,
      tag: '0.14.0',
      commit: 'abdc1312cad',
      buildpack_id: 'ruby',
      environment_name: 'staging',
      environment_id: 'some_environment_id',
      settings: { 'MONGO_URL' => 'mongodb://mongo_url' },
      class: double(:class, name: 'Deployment')
    )
  end

  it 'serializes the deployment' do
    expect(subject).to match(
      deployment_app_id: 'some_app',
      deployment_id: 'some_deployment_id',
      deployment_branch: 'master',
      deployment_state: 'ready',
      deployment_deployed_at: Time.zone.now,
      deployment_tag: '0.14.0',
      deployment_commit: 'abdc1312cad',
      deployment_buildpack_id: 'ruby',
      deployment_environment_name: 'staging',
      deployment_environment_id: 'some_environment_id',
      deployment_settings: { 'MONGO_URL' => 'mongodb://mongo_url' }
    )
  end
end
