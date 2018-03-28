class EnvironmentDestroyProcessing
  include Sidekiq::Worker

  EnvironmentNotFound = Class.new(StandardError)

  def perform(environment_id)
    @environment_id = environment_id

    load_environment

    LockService.synchronize(environment_id: environment.id) do
      EnvironmentService.destroy_components(environment)

      PrivateInterfaceService.destroy(environment)

      LocalInterfaceService.destroy(environment)

      PublicInterfaceService.destroy(environment)

      NamespaceService.destroy(environment.namespace)
    end

    HookService.call(resource: environment, action: 'destroy', value: 'success')

    environment.destroy
  end

  private

  attr_reader :environment_id, :environment

  def load_environment
    @environment ||= Environment.find(environment_id)
  rescue Mongoid::Errors::DocumentNotFound
    raise(EnvironmentNotFound, environment_id: environment_id)
  end
end
