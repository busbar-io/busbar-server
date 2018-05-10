class ResizeProcessing
  include Sidekiq::Worker

  EnvironmentNotFound = Class.new(StandardError)
  MinikubeServiceProvider = Class.new(StandardError)

  def perform(environment_id, node_id)
    @environment_id = environment_id
    @node_id = node_id

    raise(EnvironmentNotFound, environment_id: @environment_id) unless environment.present?

    if Configurations.service.provider == 'minikube'
      raise(MinikubeServiceProvider, 'Resize not allowed on Minikube.')
    end

    LockService.synchronize(environment_id: environment.id) do
      environment.update_attributes(default_node_id: node_id)
      notify_resizing
      deploy
    end
  end

  private

  def notify_resizing
    HookService.call(resource: environment, action: 'resize', value: @node_id)
  end

  def deploy
    DeploymentService.create(environment, {}, build: false, resize_components: true)
  end

  def environment
    @environment ||= Environment.find(@environment_id)
  rescue Mongoid::Errors::DocumentNotFound
    @environment = nil
  end
end
