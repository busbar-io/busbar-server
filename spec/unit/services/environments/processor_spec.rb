require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Environments::Processor do
  describe '.call' do
    let(:environment) do
      Environment.new(name: 'staging', id: 'staging', components: [web_component, worker_component])
    end

    let(:web_component) do
      Component.new(id: 'web')
    end
    let(:worker_component) do
      Component.new(id: 'worker')
    end

    subject { described_class.call(environment) }

    before do
      allow(LocalInterfaceService).to receive(:create)
      allow(PrivateInterfaceService).to receive(:create)
      allow(DeploymentService).to receive(:create)
      allow(NamespaceService).to receive(:upsert)
      allow(ComponentService).to receive(:scale)
      allow(HookService).to receive(:call)
        .with(resource: environment, action: 'create', value: 'success')
    end

    after do
      environment.destroy
      web_component.destroy
      worker_component.destroy
    end

    it "upserts the environment's namespace" do
      subject

      expect(NamespaceService).to have_received(:upsert).with(environment.namespace).once
    end

    it 'creates a private interface' do
      subject

      expect(PrivateInterfaceService).to have_received(:create)
        .with(
          app_name: environment.app_id,
          environment_name: environment.name,
          namespace: environment.namespace
        )
    end

    it 'creates a local interface' do
      subject

      expect(LocalInterfaceService).to have_received(:create)
        .with(
          app_name: environment.app_id,
          environment_name: environment.name,
          namespace: environment.namespace
        )
    end

    it 'deploys the environment' do
      subject

      expect(DeploymentService)
        .to have_received(:create)
        .with(environment,
              {
                branch: environment.default_branch,
                buildpack_id: environment.buildpack_id
              },
              sync: true
             ).once
    end

    it "scales the environment's components" do
      subject

      expect(ComponentService)
        .to have_received(:scale)
        .with(web_component, 1).once

      expect(ComponentService)
        .to have_received(:scale)
        .with(worker_component, 1).once
    end

    it "changes the give environment's state to available" do
      subject

      expect(environment.state).to eq('available')
    end

    it 'creates a notification about the environment creation' do
      expect(HookService).to receive(:call)
        .with(resource: environment, action: 'create', value: 'success')

      subject
    end
  end
end
