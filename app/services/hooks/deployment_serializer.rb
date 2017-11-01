module Hooks
  class DeploymentSerializer < HookSerializer
    private

    def serialized_attributes
      %w(id buildpack_id branch state deployed_at tag
         commit environment_name environment_id app_id settings)
    end
  end
end
