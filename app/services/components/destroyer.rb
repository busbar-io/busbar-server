module Components
  class Destroyer
    include Serviceable

    ComponentDestructionError = Class.new(StandardError)

    def call(component)
      @component = component
      uninstall
      raise(ComponentDestructionError, component_id: component.id) unless component.destroy
      component
    end

    private

    attr_reader :component

    def uninstall
      ComponentService.uninstall(component)
    end
  end
end
