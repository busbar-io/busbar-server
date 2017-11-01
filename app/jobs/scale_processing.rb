class ScaleProcessing
  include Sidekiq::Worker

  ComponentNotFound = Class.new(StandardError)
  EnvironmentNotFound = Class.new(StandardError)

  def perform(component_id, scale)
    @component_id = component_id
    raise(ComponentNotFound, component_id: component_id) unless component.present?
    raise(EnvironmentNotFound, environment_id: component.environment_id) unless environment.present?

    LockService.synchronize(environment_id: environment.id) do
      ComponentService.scale(component, scale)
    end
  end

  private

  attr_reader :component_id

  def component
    @component ||= Component.find(component_id)
  rescue Mongoid::Errors::DocumentNotFound
    @component = nil
  end

  def environment
    @environment ||= Environment.find(component.environment_id)
  rescue Mongoid::Errors::DocumentNotFound
    @environment = nil
  end
end
