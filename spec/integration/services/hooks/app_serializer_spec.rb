require 'rails_helper'

RSpec.describe Hooks::AppSerializer do
  subject { described_class.call(app) }

  let(:app) do
    instance_double(
      App,
      id: 'some_app',
      buildpack_id: 'ruby',
      repository: 'git@some_repo_url',
      default_branch: 'master',
      default_node_id: '2x.standard',
      environment_names: %w(staging production),
      class: double(:class, name: 'App')
    )
  end

  it 'serializes the app' do
    expect(subject).to match(
      app_id: 'some_app',
      app_buildpack_id: 'ruby',
      app_repository: 'git@some_repo_url',
      app_default_branch: 'master',
      app_default_node_id: '2x.standard',
      app_environment_names: %w(staging production)
    )
  end
end
