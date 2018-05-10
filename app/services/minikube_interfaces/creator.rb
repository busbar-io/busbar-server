module MinikubeInterfaces
  class Creator
    include Serviceable

    CreationError = Class.new(StandardError)

    def call(data = {})
      @data = data.with_indifferent_access

      raise(CreationError, data: data) unless interface_exist? || interface

      true
    end

    private

    attr_reader :data

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
      data.fetch('ports', [{ port: 8080, targetPort: 8080 }])
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
        spec:       { ports: ports, selector: selector, type: 'NodePort' } }
    end

    def interface
      return @interface if defined?(@interface)
      @interface ||= system("echo '#{manifest.to_json}' | "\
                            "kubectl create -f - --namespace=#{namespace}")
    end

    def interface_exist?
      system("kubectl get service/#{app_name} -o name 2>/dev/null --namespace=#{namespace} | "\
             " grep -q service/#{app_name}")
    end

    def metadata
      { name: app_name }
    end
  end
end
