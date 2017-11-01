class DatabaseDestroyProcessing
  include Sidekiq::Worker

  DatabaseNotFound = Class.new(StandardError)

  def perform(database_id)
    @database_id = database_id

    raise(DatabaseNotFound, database: database_id) unless database.present?

    LockService.synchronize(database_id: database.id) do
      destroy_service
      destroy_replication_controller
      destroy_volume

      # We need kubernetes a time to really destroy the resources above
      # before destroying the namespace itself
      sleep(Configurations.databases.destruction_wait)

      destroy_namespace

      HookService.call(resource: database, action: 'destroy', value: 'success')

      database.destroy
    end
  end

  private

  def database
    @database ||= Database.find(@database_id)
  rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
    @database = nil
  end

  def destroy_service
    system("kubectl delete service #{database.name} --namespace=#{database.namespace}")
  end

  def destroy_replication_controller
    system(
      "kubectl delete replicationcontroller #{database.name} --namespace=#{database.namespace}"
    )
  end

  def destroy_volume
    system(
      "kubectl delete persistentvolumeclaim #{database.name} --namespace=#{database.namespace}"
    )
  end

  def destroy_namespace
    NamespaceService.destroy(database.namespace)
  end
end
