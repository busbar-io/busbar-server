if @deployment.persisted?
  json.data do
    json.partial! 'deployments/deployment', deployment: @deployment
  end
else
  json.errors @deployment.errors.full_messages
end
