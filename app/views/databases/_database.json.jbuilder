json.id database.id.to_s
json.type database.type
json.namespace database.namespace
json.size "#{database.size}Gb"
json.url database.url
json.created_at database.created_at.iso8601
json.updated_at database.updated_at.iso8601
