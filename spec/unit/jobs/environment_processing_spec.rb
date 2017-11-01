require 'rails_helper'

RSpec.describe EnvironmentProcessing do
  describe '#perform' do
    let(:environment) { Environment.new }

    subject { described_class.new.perform(environment.id) }

    before do
      allow(Environment).to receive(:find).with(environment.id).and_return(environment)
      allow(LockService).to receive(:synchronize).and_yield
      allow(EnvironmentService).to receive(:process)
    end

    it 'processes the given Environment' do
      expect(EnvironmentService).to receive(:process).with(environment)
      subject
    end

    context 'when the Environment does not exist' do
      let(:error) { Mongoid::Errors::DocumentNotFound.new(Environment, [environment.id]) }

      before do
        allow(Environment).to receive(:find).with(environment.id).and_raise(error)
      end

      it 'raises the error EnvironmentNotFound' do
        expect { subject }.to raise_error(EnvironmentProcessing::EnvironmentNotFound)
      end
    end
  end
end
