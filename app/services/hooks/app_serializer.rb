module Hooks
  class AppSerializer < HookSerializer
    private

    def serialized_attributes
      %w(id buildpack_id repository default_branch default_node_id environment_names)
    end
  end
end
