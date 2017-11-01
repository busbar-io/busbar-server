if @database.persisted?
  json.data do
    json.partial! 'databases/database', database: @database
  end
else
  json.errors @database.errors.full_messages
end
