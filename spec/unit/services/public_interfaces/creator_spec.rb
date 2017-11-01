require 'rails_helper'

RSpec.describe PublicInterfaces::Creator do
  describe '.call' do
    let(:label_prefix) { Configurations.kubernetes.label_prefix }
    let(:app_name) { 'test' }
    let(:dns_provider) { Configurations.dns.public.provider }
    let(:domain_name) { Configurations.dns.public.domain_name }
    let(:cluster_name) { Configurations.cluster.name }
    let(:environment_name) { 'staging' }
    let(:service_name) { 'test-staging-public' }
    let(:ports) { [{ port: 8000, targetPort: 8000 }] }
    let(:component) { 'web' }
    let(:namespace) { 'staging' }
    let(:data) do
      {
        environment_name: environment_name,
        app_name: app_name,
        namespace: namespace,
        ports: ports,
        component: component
      }
    end

    let(:selector) do
      { "#{label_prefix}/environment" => environment_name,
        "#{label_prefix}/app" => app_name,
        "#{label_prefix}/component" => component }
    end

    let(:manifest) do
      {
        kind: 'Service',
        apiVersion: 'v1',
        metadata: {
          name: service_name,
          annotations: {
            'service.beta.kubernetes.io/aws-load-balancer-ssl-cert' =>
              Configurations.interfaces.ssl_certificate,
            'service.beta.kubernetes.io/aws-load-balancer-backend-protocol' => 'http',
            'service.beta.kubernetes.io/aws-load-balancer-ssl-ports': '443'
          }
        },
        spec: { ports: ports, selector: selector, type: 'LoadBalancer' }
      }
    end

    let(:create_command) do
      "echo '#{manifest.to_json}' | kubectl create -f - --namespace=#{namespace}"
    end

    let(:find_command) do
      "kubectl get service/#{service_name} -o name 2>/dev/null --namespace=#{namespace} | "\
      "grep -q service/#{service_name}"
    end

    subject { described_class.call(data) }

    before do
      allow_any_instance_of(described_class).to receive(:system)
        .with(find_command)
        .and_return(true)

      allow_any_instance_of(described_class).to receive(:system)
        .with(create_command)
        .and_return(true)

      allow(DnsService).to receive(:create_zone)
        .and_return(true)

      allow(Interfaces::Getter).to receive(:call)
        .and_return(hostname: 'test')
    end

    it 'creates the public zone' do
      expect(DnsService).to receive(:create_zone)
        .with(
          dns_provider,
          domain_name,
          "#{app_name}.#{environment_name}.#{cluster_name}",
          'test').once
      subject
    end

    context 'when the interface does not exist' do
      before do
        allow_any_instance_of(described_class).to receive(:system)
          .with(find_command)
          .and_return(false)
      end

      it 'creates the interface' do
        expect_any_instance_of(described_class).to receive(:system)
          .with(create_command)
          .once

        subject
      end
    end

    context 'when it fails to create the interface' do
      before do
        allow_any_instance_of(described_class).to receive(:system)
          .with(create_command)
          .and_return(false)

        allow_any_instance_of(described_class).to receive(:system)
          .with(find_command)
          .and_return(false)
      end

      it 'raises a CreationError' do
        expect { subject }.to raise_error(PublicInterfaces::Creator::CreationError)
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
