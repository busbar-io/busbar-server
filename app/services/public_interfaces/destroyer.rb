module PublicInterfaces
  class Destroyer
    include Serviceable

    # This method uses `environment.id` while all the others uses `environment.name`.
    # We are keeping like this to not break compatibility with current busbar installations.
    def call(environment)
      @environment = environment
      @service = "#{environment.app_id}-#{environment.id}-public"
      if environment.public?
        uninstall(@service) if exists?(@service)
      end
    end

    private

    attr_reader :environment
    DestructionError = Class.new(StandardError)

    def exists?(service)
      cmd = "kubectl get service #{service} --namespace #{environment.namespace}"
      system(cmd)
    end

    def uninstall(service)
      cmd    = "kubectl delete service #{service} --namespace=#{environment.namespace}"
      result = system(cmd)
      raise(DestructionError) unless result
    end
  end
end
