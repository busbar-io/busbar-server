module Components
  class Scaler
    include Serviceable

    ComponentScalingError = Class.new(StandardError)

    def call(component, scale)
      @component = component
      @scale = scale

      update_and_scale_component

      notify_scaling

      component
    end

    private

    attr_reader :component, :scale

    def update_and_scale_component
      update_component_scale if update_component
    end

    def update_component
      component.update_attributes(scale: scale)
    end

    def update_component_scale
      cmd    = "kubectl scale --replicas=#{component.scale}"\
                " deployment #{component.name} --namespace=#{component.namespace}"
      result = system(cmd)

      raise(ComponentScalingError, component_id: component.id,
                                   cmd:          cmd,
                                   result:       result) unless result
    end

    def notify_scaling
      HookService.call(resource: component, action: 'scale', value: scale)
    end
  end
end
