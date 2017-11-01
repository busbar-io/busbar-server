module Hooks
  class ComponentSerializer < HookSerializer
    private

    def serialized_attributes
      %w(type command node_id scale state environment_id name
         app_id settings namespace environment_name)
    end
  end
end
