if @setting.errors.blank?
  json.data do
    json.partial! 'settings/setting', setting: @setting
  end
else
  json.errors @setting.errors.full_messages
end
