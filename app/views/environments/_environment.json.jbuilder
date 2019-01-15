json.id environment.id.to_s
json.app_id environment.app_id
json.name environment.name
json.namespace environment.namespace
json.state environment.state
json.public environment.public
json.default_branch environment.default_branch
json.buildpack_id environment.buildpack_id
json.created_at environment.created_at.iso8601
json.updated_at environment.updated_at.iso8601
json.default_node_id environment.default_node_id
json.settings environment.settings
json.components Component.where(
  environment_id: Environment.where(name: environment.name).where(app_id: environment.app_id).pluck(:id)[0]
).pluck(:type, :node_id, :scale).map { |type, node_id, scale| { type: type, node_id:  node_id, scale: scale } }
