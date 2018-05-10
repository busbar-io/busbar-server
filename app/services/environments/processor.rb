module Environments
  class Processor
    include Serviceable

    def call(environment)
      @environment = environment

      environment.checkout! if environment.may_checkout?

      upsert_environment_namespace

      create_local_interface

      create_private_interface

      deploy

      scale_components

      environment.finish!

      notify_creation
    end

    private

    attr_reader :environment

    def upsert_environment_namespace
      NamespaceService.upsert(environment.namespace)
    end

    def create_private_interface
      if Configurations.service.provider != 'minikube'
        PrivateInterfaceService.create(
          {
            app_name: environment.app_id,
            environment_name: environment.name,
            namespace: environment.namespace
          }.with_indifferent_access
        )
      end
    end

    def create_local_interface
      if Configurations.service.provider == 'minikube'
        MinikubeInterfaceService.create(
          {
            app_name: environment.app_id,
            environment_name: environment.name,
            namespace: environment.namespace
          }.with_indifferent_access
        )

      elsif Configurations.service.provider == 'aws'
        LocalInterfaceService.create(
          {
            app_name: environment.app_id,
            environment_name: environment.name,
            namespace: environment.namespace
          }.with_indifferent_access
        )
      end
    end

    def deploy
      DeploymentService.create(
        environment,
        deployment_params,
        deployment_options
      )
    end

    def deployment_params
      {
        branch: environment.default_branch,
        buildpack_id: environment.buildpack_id
      }
    end

    def deployment_options
      { sync: true }
    end

    def scale_components
      environment.components.each do |component|
        ComponentService.scale(component, 1)
      end
    end

    def notify_creation
      HookService.call(resource: environment, action: 'create', value: 'success')
    end
  end
end
