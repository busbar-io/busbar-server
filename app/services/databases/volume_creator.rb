module Databases
  class VolumeCreator
    include Serviceable

    VolumeCreationError = Class.new(StandardError)

    def call(database)
      @database = database

      raise VolumeCreationError unless create_volume
    end

    private

    def create_volume
      system("echo '#{manifest.to_json}' | "\
             "kubectl create -f - --namespace=#{@database.namespace}")
    end

    def manifest
      {
        kind: 'PersistentVolumeClaim',
        apiVersion: 'v1',
        metadata: {
          name: @database.name,
          annotations: {
            'volume.beta.kubernetes.io/storage-class' => 'standard'
          }
        },
        spec: {
          accessModes: ['ReadWriteOnce'],
          resources: {
            requests: {
              storage: "#{@database.size}Gi"
            }
          }
        }
      }
    end
  end
end
