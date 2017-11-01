require 'rails_helper'

RSpec.describe Components::Destroyer do
  describe '.call' do
    let(:component)             { Component.new(id: 'test') }
    let(:uninstalled_component) { Component.new(id: 'test', state: :uninstalled) }

    subject { described_class.call(component) }

    before do
      allow(ComponentService).to receive(:uninstall)
        .with(component)
        .and_return(uninstalled_component)

      allow(component).to receive(:destroy).and_return(true)
    end

    it 'returns the uninstalled the component' do
      is_expected.to eq uninstalled_component
    end

    context 'when it fails to uninstall the component' do
      before do
        allow(ComponentService).to receive(:uninstall)
          .with(component)
          .and_raise(Components::Uninstaller::ComponentUninstallationError)
      end

      it 'raises the ComponentUninstallationError error' do
        expect { subject }.to raise_error(Components::Uninstaller::ComponentUninstallationError)
      end
    end

    context 'when it fails to destroy the component' do
      before do
        allow(component).to receive(:destroy).and_return(false)
      end

      it 'raises the ComponentDestructionError error' do
        expect { subject }.to raise_error(Components::Destroyer::ComponentDestructionError)
      end
    end
  end
end
