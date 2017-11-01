class DatabaseProcessing
  include Sidekiq::Worker

  DatabaseNotFound = Class.new(StandardError)

  def perform(database_id)
    @database_id = database_id

    LockService.synchronize(database_id: database.id) do
      DatabaseService.process(database)
    end
  end

  private

  def database
    @database ||= Database.find(@database_id)
  rescue Mongoid::Errors::DocumentNotFound
    raise(DatabaseNotFound, database_id: @database_id)
  end
end
