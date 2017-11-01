require 'rails_helper'

RSpec.describe Namespaces::Upserter do
  describe '.call' do
    subject { described_class.call(namespace) }

    let(:namespace) { 'staging' }
    let(:command) { "kubectl create namespace #{namespace}" }

    before do
      allow_any_instance_of(described_class)
        .to receive(:system).with("kubectl get ns #{namespace}").and_return(namespace_exists)
    end

    context 'when the given namespace exists' do
      let(:namespace_exists) { true }

      it 'does not try to create the namespace again' do
        expect_any_instance_of(described_class)
          .to_not receive(:system)
          .with(command)

        subject
      end
    end

    context 'when the given namespace does not exist' do
      let(:namespace_exists) { false }

      it 'creates the namespace' do
        expect_any_instance_of(described_class)
          .to receive(:system)
          .with(command).once

        subject
      end
    end
  end
end
