module Databases
  class Creator
    include Serviceable

    def call(data = {})
      @data = data.with_indifferent_access
      return database unless database.valid?

      schedule_processing

      database
    end

    private

    def database
      @database ||= Database.create(@data)
    end

    def schedule_processing
      DatabaseProcessing.perform_async(database.id.to_s)
    end
  end
end
