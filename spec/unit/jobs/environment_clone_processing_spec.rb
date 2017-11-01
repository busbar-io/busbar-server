require 'rails_helper'

RSpec.describe EnvironmentCloneProcessing do
  describe '#perform' do
    let(:environment) { instance_double(Environment, id: SecureRandom.hex) }

    subject { described_class.new.perform(environment.id, 'clone_name') }

    before do
      allow(Environment).to receive(:find).and_return(environment)
      allow(LockService).to receive(:synchronize).with(environment_id: environment.id).and_yield
      allow(EnvironmentService).to receive(:clone)
        .with(environment, 'clone_name')
    end

    it 'locks the environment before changing it' do
      expect(LockService).to receive(:synchronize)
        .with(environment_id: environment.id)
        .and_yield
        .once

      subject
    end

    it 'clones the environment' do
      expect(EnvironmentService).to receive(:clone)
        .with(environment, 'clone_name')
      subject
    end

    context 'when the environment does not exist' do
      let(:error) { Mongoid::Errors::DocumentNotFound.new(Environment, [environment.id]) }

      before do
        allow(Environment).to receive(:find).and_raise(error)
      end

      it 'raises an EnvironmentNotFound error' do
        expect { subject }.to raise_error(EnvironmentCloneProcessing::EnvironmentNotFound)
      end

      it 'does not clone the environment' do
        begin
          subject
        rescue EnvironmentCloneProcessing::EnvironmentNotFound
          expect(EnvironmentService).to_not have_received(:clone)
        end
      end
    end
  end
end
