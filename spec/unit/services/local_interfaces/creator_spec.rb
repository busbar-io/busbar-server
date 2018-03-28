require 'rails_helper'

RSpec.describe LocalInterfaces::Creator do
  describe '.call' do
    let(:label_prefix) { Configurations.kubernetes.label_prefix }
    let(:app_name) { 'test' }
    let(:ports) { [{ port: 8000, targetPort: 8000 }] }
    let(:component) { 'web' }
    let(:environment_name) { 'staging' }
    let(:namespace) { 'staging' }
    let(:data) do
      {
        app_name: app_name,
        ports: ports,
        component: component,
        environment_name: environment_name,
        namespace: namespace
      }
    end

    let(:selector) do
      { "#{label_prefix}/environment" => environment_name,
        "#{label_prefix}/app" => app_name,
        "#{label_prefix}/component" => component }
    end

    let(:manifest) do
      { kind:       'Service',
        apiVersion: 'v1',
        metadata:   { name: app_name },
        spec:       { ports: ports, selector: selector, type: 'ClusterIP' } }
    end

    let(:create_command) do
      "echo '#{manifest.to_json}' | kubectl create -f - --namespace=#{namespace}"
    end

    let(:find_command) do
      "kubectl get service/#{app_name} -o name 2>/dev/null "\
      "--namespace=#{namespace} | grep -q service/#{app_name}"
    end

    subject { described_class.call(data) }

    before do
      allow_any_instance_of(described_class).to receive(:system)

      allow_any_instance_of(described_class).to receive(:system)
        .with(find_command)
        .and_return(false)

      allow_any_instance_of(described_class).to receive(:system)
        .with(create_command)
        .and_return(true)

      allow(DnsService).to receive(:create_zone).and_return(true)

      allow(Interfaces::Getter).to receive(:call).and_return(hostname: 'some.host')
    end

    it 'creates the interface' do
      expect_any_instance_of(described_class).to receive(:system).with(create_command)
      subject
    end

    context 'when it fails to create the interface' do
      before do
        allow_any_instance_of(described_class).to receive(:system)
          .with(create_command)
          .and_return(false)
      end

      it 'raises a CreationError' do
        expect { subject }.to \
          raise_error(LocalInterfaces::Creator::CreationError)
      end
    end

    context 'when the interface already exists' do
      before do
        allow_any_instance_of(described_class).to receive(:system)
          .with(find_command)
          .and_return(true)
      end

      it 'does not attempt to create the interface again' do
        expect_any_instance_of(described_class).not_to receive(:system).with(create_command)
      end
    end
  end
end
