if @app.persisted?
  json.data do
    json.partial! 'apps/app', app: @app
  end
else
  json.errors @app.errors.full_messages
end
