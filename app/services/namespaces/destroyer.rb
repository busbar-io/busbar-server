module Namespaces
  class Destroyer
    include Serviceable

    RESOURCE_TYPES = %w(daemonsets deployments horizontalpodautoscalers
                        ingresses jobs persistentvolumeclaims pods
                        replicasets replicationcontrollers services).freeze

    def call(namespace)
      @namespace = namespace

      destroy_namespace if namespace_empty?
    end

    private

    def destroy_namespace
      system("kubectl delete namespace #{@namespace}")
    end

    def namespace_empty?
      RESOURCE_TYPES.each do |resource_type|
        return false if resources_exists?(resource_type)
      end

      true
    end

    def resources_exists?(resource)
      `kubectl --namespace #{@namespace} get #{resource} -o name --no-headers`.split("\n").count > 0
    end
  end
end
