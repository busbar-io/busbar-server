require 'rails_helper'

RSpec.describe Namespaces::Destroyer do
  describe '.call' do
    subject { described_class.call('staging') }

    RESOURCE_TYPES = %w(daemonsets deployments horizontalpodautoscalers
                        ingresses jobs persistentvolumeclaims pods
                        replicasets replicationcontrollers services).freeze

    before do
      RESOURCE_TYPES.each do |resource_type|
        allow_any_instance_of(described_class).to receive(:`)
          .with("kubectl --namespace staging get #{resource_type} -o name --no-headers")
          .and_return('')
      end

      allow_any_instance_of(described_class).to receive(:system)
    end

    it 'destroys the namespace' do
      expect_any_instance_of(described_class).to receive(:system)
        .with('kubectl delete namespace staging')
        .once

      subject
    end

    context 'when there are existing resources' do
      before do
        RESOURCE_TYPES.each do |resource_type|
          allow_any_instance_of(described_class).to receive(:`)
            .with("kubectl --namespace staging get #{resource_type} -o name --no-headers")
            .and_return("resource-a\nresource-b")
        end
      end

      it 'does not destroy the namespace' do
        expect_any_instance_of(described_class).to_not receive(:system)

        subject
      end
    end
  end
end
