json.id app.id.to_s
json.default_branch app.default_branch
json.buildpack_id app.buildpack_id
json.repository app.repository
json.environments app.environment_names
json.created_at app.created_at.iso8601
json.updated_at app.updated_at.iso8601
