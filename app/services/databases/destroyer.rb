module Databases
  class Destroyer
    include Serviceable

    def call(database)
      return false if database.nil?

      DatabaseDestroyProcessing.perform_async(database.id)
    end
  end
end
