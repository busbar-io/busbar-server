class Settings::SettingUpserter
  include Serviceable

  def call(environment, update_query)
    return if update_query.empty?

    update = { '$set' => update_query }

    operation = Environment
                .where(id: environment.id)
                .find_one_and_update(update, upsert: true, return_document: :after)

    environment.reload if operation
  end
end
