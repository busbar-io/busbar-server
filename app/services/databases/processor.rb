module Databases
  class Processor
    include Serviceable

    def call(database)
      @database = database

      upsert_namespace

      create_volume

      create_replication_controller

      create_service

      notify_database_creation

      @database
    end

    private

    def upsert_namespace
      NamespaceService.upsert(@database.namespace)
    end

    def create_volume
      DatabaseService.create_volume(@database)
    end

    def create_replication_controller
      DatabaseService.create_replication_controller(@database)
    end

    def create_service
      DatabaseService.create_service(@database)
    end

    def notify_database_creation
      HookService.call(
        resource: @database,
        action: 'create',
        value: 'success'
      )
    end
  end
end
