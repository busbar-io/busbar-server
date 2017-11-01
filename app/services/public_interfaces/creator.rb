module PublicInterfaces
  class Creator
    include Serviceable

    CreationError = Class.new(StandardError)

    def call(data = {})
      @data = data.with_indifferent_access

      raise(CreationError, data: data) unless interface_exist? || interface

      lb = Interfaces::Getter.call(service_name, namespace)

      DnsService.create_zone(
        dns_provider,
        domain_name,
        "#{app_name}.#{environment_name}.#{cluster_name}",
        lb[:hostname])
      true
    end

    private

    attr_reader :data

    def service_name
      "#{app_name}-#{environment_name}-public"
    end

    def dns_provider
      Configurations.dns.public.provider
    end

    def domain_name
      Configurations.dns.public.domain_name
    end

    def cluster_name
      Configurations.cluster.name
    end

    def app_name
      data.fetch('app_name')
    end

    def environment_name
      data.fetch('environment_name')
    end

    def namespace
      data.fetch('namespace')
    end

    def ports
      data.fetch('ports',
                 [
                   {
                     port: 80,
                     protocol: 'TCP',
                     targetPort: 8080,
                     name: 'http'
                   },
                   {
                     port: 443,
                     protocol: 'TCP',
                     targetPort: 8080,
                     name: 'https'
                   }
                 ]
                )
    end

    def component
      data.fetch('component', 'web')
    end

    def selector(prefix = Configurations.kubernetes.label_prefix)
      { "#{prefix}/environment" => environment_name,
        "#{prefix}/app" => app_name,
        "#{prefix}/component" => component }
    end

    def manifest
      { kind:       'Service',
        apiVersion: 'v1',
        metadata:   metadata,
        spec:       { ports: ports, selector: selector, type: 'LoadBalancer' } }
    end

    def interface
      return @interface if defined?(@interface)
      @interface ||= system("echo '#{manifest.to_json}' | "\
                            "kubectl create -f - --namespace=#{namespace}")
    end

    def interface_exist?
      system("kubectl get service/#{service_name} -o name 2>/dev/null --namespace=#{namespace} | " \
              "grep -q service/#{service_name}")
    end

    def metadata
      {
        name: service_name,
        annotations: {
          'service.beta.kubernetes.io/aws-load-balancer-ssl-cert' =>
            Configurations.interfaces.ssl_certificate,
          'service.beta.kubernetes.io/aws-load-balancer-backend-protocol' => 'http',
          'service.beta.kubernetes.io/aws-load-balancer-ssl-ports': '443'
        }
      }
    end
  end
end
