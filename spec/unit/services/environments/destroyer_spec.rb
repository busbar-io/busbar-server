require 'rails_helper'

RSpec.describe Environments::Destroyer do
  describe '.call' do
    subject { described_class.call(environment) }

    let(:environment) { instance_double(Environment, id: SecureRandom.hex) }

    it 'processes the environment destruction' do
      expect(EnvironmentDestroyProcessing).to receive(:perform_async).with(environment.id)

      subject
    end
  end
end
