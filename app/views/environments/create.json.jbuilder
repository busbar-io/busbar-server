if @environment.persisted?
  json.data do
    json.partial! 'environments/environment', environment: @environment
  end
else
  json.errors @environment.errors.full_messages
end
