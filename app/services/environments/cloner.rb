module Environments
  class Cloner
    include Serviceable

    def call(environment, clone_name)
      environment = EnvironmentService.create(
        environment.app,
        name: clone_name || "#{environment.name}-clone",
        buildpack_id: environment.buildpack_id,
        default_branch: environment.default_branch,
        public: environment.public,
        default_node_id: environment.default_node_id,
        settings: environment.settings
      )

      HookService.call(resource: environment, action: 'create', value: 'success')

      environment
    end
  end
end
