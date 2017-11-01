json.data do
  json.array! @databases, partial: 'databases/database', as: :database
end
