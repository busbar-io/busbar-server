module Databases
  class ReplicationControllerCreator
    include Serviceable

    ReplicationControllerCreationError = Class.new(StandardError)

    def call(database)
      @database = database

      raise ReplicationControllerCreationError unless create_replication_controller
    end

    private

    def create_replication_controller
      system("echo '#{manifest.to_json}' | "\
             "kubectl create -f - --namespace=#{@database.namespace}")
    end

    def manifest
      {
        apiVersion: 'v1',
        kind: 'ReplicationController',
        metadata: metadata,
        spec: spec
      }
    end

    def metadata
      {
        name: @database.name,
        labels: {
          app: @database.id,
          component: @database.type,
          role: @database.role
        }
      }
    end

    def spec
      {
        replicas: 1,
        selector: {
          app: @database.id,
          component: @database.type,
          role: @database.role
        },
        template: template_data
      }
    end

    def template_data
      {
        metadata: {
          labels: {
            app: @database.name,
            component: @database.type,
            role: @database.role
          }
        },
        spec: {
          containers: [
            container_data
          ],
          volumes: [
            volume_data
          ]
        }
      }
    end

    def container_data
      {
        name: @database.type,
        image: @database.image,
        ports: [
          {
            name: "#{@database.type}-port",
            containerPort: @database.port,
            hostPort: @database.port
          }
        ],
        volumeMounts: [
          {
            name: @database.name,
            mountPath: @database.path
          }
        ]
      }
    end

    def volume_data
      {
        name: @database.name,
        persistentVolumeClaim: {
          claimName: @database.name
        }
      }
    end
  end
end
