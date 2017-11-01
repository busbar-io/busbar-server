module Hooks
  class EnvironmentSerializer < HookSerializer
    private

    def serialized_attributes
      %w(app_id name namespace buildpack_id state public default_branch default_node_id repository)
    end
  end
end
