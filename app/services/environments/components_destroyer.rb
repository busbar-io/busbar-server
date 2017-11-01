module Environments
  class ComponentsDestroyer
    include Serviceable

    def call(environment)
      environment.components.each do |component|
        ComponentService.destroy(component)
      end
    end
  end
end
