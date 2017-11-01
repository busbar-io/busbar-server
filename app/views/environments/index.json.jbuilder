json.data do
  json.array! @environments, partial: 'environments/environment', as: :environment
end
