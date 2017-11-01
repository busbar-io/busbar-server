module Databases
  class ServiceCreator
    include Serviceable

    ServiceCreationError = Class.new(StandardError)

    def call(database)
      @database = database

      raise ServiceCreationError unless create_volume
    end

    private

    def create_volume
      system("echo '#{manifest.to_json}' | "\
             "kubectl create -f - --namespace=#{@database.namespace}")
    end

    def manifest
      {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          name: @database.name,
          labels: {
            app: @database.name,
            component: @database.type,
            role: @database.role
          }
        },
        spec: {
          ports: [
            {
              port: @database.port,
              targetPort: @database.port
            }
          ],
          selector: {
            app: @database.name,
            component: @database.type,
            role: @database.role
          }
        }
      }
    end
  end
end
