class HookService
  include Serviceable

  def call(resource:, action:, value:, timestamp: Time.zone.now)
    return unless Configurations.hooks.url

    @resource = resource
    @action = action
    @value = value
    @timestamp = timestamp.iso8601

    response = Http::PostService.call(
      message,
      Configurations.hooks.url
    )

    data = {
      service: 'hook_service',
      url: Configurations.hooks.url,
      data: message,
      response: response
    }.to_json

    Rails.logger.info(data)

    response
  end

  private

  attr_reader :resource, :action, :value, :timestamp

  def message
    {
      data: {
        cluster: Configurations.cluster.name,
        resource_type: resource.class.name.downcase,
        resource: serialized_resource,
        action: action,
        info: value,
        timestamp: timestamp
      }
    }
  end

  def serialized_resource
    "Hooks::#{resource.class.name}Serializer".constantize.call(resource)
  end
end
