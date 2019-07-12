module Components
  class Uninstaller
    include Serviceable
    extend Forwardable

    ComponentUninstallationError = Class.new(StandardError)

    def call(component)
      @component = component

      uninstall if exists?

      component
    end

    private

    attr_reader :component

    def exists?
      cmd = "kubectl get deployment #{component.name} --namespace #{component.namespace}"
      system(cmd)
    end

    def uninstall
      cmd    = "kubectl delete deployment #{component.name} --namespace=#{component.namespace}"
      result = system(cmd)

      raise(ComponentUninstallationError, component_id: component.id,
                                          cmd:          cmd,
                                          result:       result) unless result

      component.uninstall!
    end
  end
end
