@settings.each do |setting|
  if setting.valid? && setting.errors.blank?
    json.data do
      json.set! setting.key, setting.value
    end
  else
    json.errors do
      json.set! setting.key do
        json.set! :value, setting.value
        json.set! :messages, setting.errors.full_messages
      end
    end
  end
end
