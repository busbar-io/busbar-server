class PublishProcessing
  include Sidekiq::Worker

  EnvironmentNotFound = Class.new(StandardError)
  MinikubeServiceProvider = Class.new(StandardError)

  def perform(environment_id)
    @environment_id = environment_id
    raise(EnvironmentNotFound, environment_id: @environment_id) unless environment.present?

    if Configurations.service.provider == 'minikube'
      raise(MinikubeServiceProvider, 'Publish not allowed on Minikube.')
    end

    LockService.synchronize(environment_id: environment_id) do
      environment.update_attributes(public: true)
      PublicInterfaceService.create(
        app_name: environment.app_id,
        environment_name: environment.name,
        namespace: environment.namespace
      )
    end
  end

  private

  attr_reader :environment_id

  def environment
    @environment ||= Environment.find(environment_id)
  rescue Mongoid::Errors::DocumentNotFound
    @environment = nil
  end
end
