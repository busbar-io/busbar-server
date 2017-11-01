json.data do
  json.array! @apps, partial: 'apps/app', as: :app
end
