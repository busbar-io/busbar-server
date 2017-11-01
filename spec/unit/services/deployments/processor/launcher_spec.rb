require 'rails_helper'

RSpec.describe Deployments::Processor::Launcher do
  describe '.call' do
    let(:settings) { Hash.new }
    let(:environment) { Environment.new(settings: settings) }
    let(:commands) { { web: 'bundle exec web' } }
    let(:build) { Build.new(environment: environment, commands: commands) }
    let(:deployment) { Deployment.new(environment: environment, build: build) }
    let(:log) { instance_double(Log, append_step: true) }
    let(:options) { { resize_components: true } }

    let(:component_data) do
      type = build.commands.keys.first

      { 'environment_id' => environment.id.to_s,
        'image_url' => build.image_url,
        'settings' => deployment.settings,
        'command' => build.commands[type],
        'type' => type,
        'node_id' => '1x.standard' }
    end

    subject { described_class.call(deployment, options) }

    before do
      allow(build).to receive(:log).and_return(log)
      allow(Component).to receive_message_chain(:where, :nin)
      allow(ComponentService).to receive(:upsert).with(environment, component_data, options)
    end

    it 'upserts the components' do
      expect(ComponentService).to receive(:upsert).with(environment, component_data, options)
      subject
    end

    it 'appends a message about upserting the components' do
      expect(log).to receive(:append_step).with('Upserting web component')

      subject
    end

    context 'when there are deprecated components' do
      let(:deprecated_components) { [Component.new] }

      before do
        allow(Component).to receive_message_chain(:where, :nin).and_return(deprecated_components)
        allow(ComponentService).to receive(:destroy)
      end

      it 'appends a message about deprecating old components' do
        expect(log).to receive(:append_step).with('Deprecating old components')

        subject
      end

      it 'uninstalls deprecated components' do
        deprecated_components.each do |component|
          expect(ComponentService).to receive(:destroy).with(component)
        end

        subject
      end
    end

    context 'when the launch fails' do
      before do
        allow_any_instance_of(described_class).to receive(:launch).and_return(false)
      end

      it 'raises a DeploymentLaunchError' do
        expect { subject }.to raise_error(Deployments::Processor::Launcher::DeploymentLaunchError)
      end

      it 'appends a message about launching failure' do
        begin
          subject
        rescue Deployments::Processor::Launcher::DeploymentLaunchError
          expect(log).to have_received(:append_step).with('Lauching failed')
        end
      end
    end

    context 'when the deployment fails to upsert the components' do
      before do
        allow_any_instance_of(described_class).to receive(:upsert_components).and_return(false)
      end

      it 'raises a DeploymentLaunchError' do
        expect { subject }.to raise_error(Deployments::Processor::Launcher::DeploymentLaunchError)
      end

      it 'appends a message about launching failure' do
        begin
          subject
        rescue Deployments::Processor::Launcher::DeploymentLaunchError
          expect(log).to have_received(:append_step).with('Lauching failed')
        end
      end
    end

    context 'when the deployment fails to uninstall deprecated components' do
      before do
        allow_any_instance_of(described_class).to receive(:upsert_components).and_return(true)
        allow_any_instance_of(described_class).to receive(:uninstall_deprecated_components)
          .and_return(false)
      end

      it 'raises a DeploymentLaunchError' do
        expect { subject }.to raise_error(Deployments::Processor::Launcher::DeploymentLaunchError)
      end

      it 'appends a message about launching failure' do
        begin
          subject
        rescue Deployments::Processor::Launcher::DeploymentLaunchError
          expect(log).to have_received(:append_step).with('Lauching failed')
        end
      end
    end
  end
end
