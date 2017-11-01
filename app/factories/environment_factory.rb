class EnvironmentFactory
  include Serviceable

  def call(data: {}, app:)
    Environment.new(
      id: data.fetch(:id, BSON::ObjectId.new.to_s),
      app_id: app.id,
      name: data.fetch(:name, Configurations.environments.default_name),
      buildpack_id: data.fetch(:buildpack_id, app.buildpack_id),
      default_branch: data.fetch(:default_branch, app.default_branch),
      public: data.fetch(:public, false),
      default_node_id: data.fetch(:default_node_id, app.default_node_id),
      settings: data.fetch(:settings, {})
    )
  end
end
