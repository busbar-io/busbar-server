require 'rails_helper'

RSpec.describe Components::Installer do
  describe '.call' do
    let(:component)     { Component.new(environment: environment) }
    let(:environment)   { Environment.new(name: 'staging') }
    let(:log)           { instance_double(Log, append_step: true) }
    let(:manifest_file) { instance_double(Tempfile, path: '/some/path') }
    let(:command) do
      "kubectl apply -f #{manifest_file.path} --namespace=#{environment.namespace}"
    end

    subject { described_class.call(component) }

    before do
      allow(CommandExecutorAndLogger).to receive(:call).with(command, log).and_return(true)
      allow(component).to receive(:manifest_file).and_return(manifest_file)
      allow(component).to receive(:install)
      allow(component).to receive(:log).and_return(log)
      allow(component).to receive(:may_install?).and_return(true)
    end

    it 'appends a message about installing the component' do
      expect(log).to receive(:append_step).with('Installing Component')

      subject
    end

    it 'runs the kubernetes commands to install the component' do
      expect(CommandExecutorAndLogger).to receive(:call).with(command, log).once

      subject
    end

    it 'installs the component' do
      expect(component).to receive(:install!).once

      subject
    end

    context 'when the component may not be installed' do
      before do
        allow(component).to receive(:may_install?).and_return(false)
      end

      it 'does not install the component' do
        expect(component).to_not receive(:install!)

        subject
      end
    end

    context 'when the component installation fails' do
      before do
        allow(CommandExecutorAndLogger).to receive(:call).with(command, log).and_return(false)
      end

      it 'raises a ComponentInstallationError' do
        expect { subject }.to raise_error(Components::Installer::ComponentInstallationError)
      end

      it 'appends a message about installing the component' do
        begin
          subject
        rescue Components::Installer::ComponentInstallationError
          expect(log).to have_received(:append_step).with('Error while installing component').once
        end
      end
    end
  end
end
