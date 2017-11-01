module Hooks
  class HookSerializer
    include Serviceable

    def call(resource)
      serialized_attributes.each_with_object({}) do |attribute, result|
        result["#{resource.class.name.downcase}_#{attribute}".to_sym] = resource.send(attribute)
      end
    end

    private

    def serialized_attributes
      raise NotImplementedError
    end
  end
end
