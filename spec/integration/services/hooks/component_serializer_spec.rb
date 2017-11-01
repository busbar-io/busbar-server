require 'rails_helper'

RSpec.describe Hooks::ComponentSerializer do
  subject { described_class.call(component) }

  let(:component) do
    instance_double(
      Component,
      app_id: 'some_app',
      type: 'web',
      state: 'new',
      command: 'bundle exec rails s',
      node_id: 'some_node_id',
      scale: 2,
      environment_id: 'some_environment_id',
      name: 'some_app_id-some_environment_id-web',
      settings: { 'MONGO_URL' => 'mongodb://mongo_url' },
      namespace: 'staging',
      environment_name: 'staging',
      class: double(:class, name: 'Component')
    )
  end

  it 'serializes the component' do
    expect(subject).to match(
      component_app_id: 'some_app',
      component_type: 'web',
      component_state: 'new',
      component_command: 'bundle exec rails s',
      component_node_id: 'some_node_id',
      component_scale: 2,
      component_environment_id: 'some_environment_id',
      component_name: 'some_app_id-some_environment_id-web',
      component_settings: { 'MONGO_URL' => 'mongodb://mongo_url' },
      component_namespace: 'staging',
      component_environment_name: 'staging'
    )
  end
end
