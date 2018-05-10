class Components::ResizeProcessing
  include Sidekiq::Worker

  ComponentNotFound = Class.new(StandardError)
  MinikubeServiceProvider = Class.new(StandardError)

  def perform(component_id, node_id)
    @component_id = component_id
    @node_id = node_id

    if Configurations.service.provider == 'minikube'
      raise(MinikubeServiceProvider, 'Resize not allowed on Minikube.')
    end

    LockService.synchronize(component_id: component.id) do
      component.update_attributes(node_id: node_id)
    end

    notify_resizing

    deploy
  end

  private

  def deploy
    DeploymentService.create(component.environment, {}, build: false)
  end

  def component
    @component ||= Component.find(@component_id)
  rescue Mongoid::Errors::DocumentNotFound
    raise(ComponentNotFound, component_id: @component_id)
  end

  def notify_resizing
    HookService.call(resource: component, action: 'resize', value: @node_id)
  end
end
