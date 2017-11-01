require 'rails_helper'

RSpec.describe Components::Uninstaller do
  describe '.call' do
    let(:environment) { Environment.new(id: 'test') }
    let(:component) { Component.new(type: 'web', environment_id: environment.id) }
    let(:command) { 'kubectl delete deployment some_app-staging-worker --namespace=staging' }

    subject { described_class.call(component) }

    before do
      allow_any_instance_of(described_class).to receive(:system).with(command).and_return(true)
      allow(component).to receive(:uninstall!).and_return(true)
      allow(component).to receive(:name).and_return('some_app-staging-worker')
      allow(component).to receive(:namespace).and_return('staging')
    end

    it 'uninstalls the component' do
      expect_any_instance_of(described_class).to receive(:system).with(command)
      subject
    end

    context 'when it fails to uninstall the component' do
      before do
        allow_any_instance_of(described_class).to receive(:system).with(command).and_return(false)
      end

      it 'raises a ComponentUninstallationError error' do
        expect { subject }.to raise_error(Components::Uninstaller::ComponentUninstallationError)
      end
    end
  end
end
