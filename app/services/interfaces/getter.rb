module Interfaces
  class Getter
    include Serviceable

    InterfaceGettingError = Class.new(StandardError)

    def call(service_name, namespace)
      @service_name = service_name
      @namespace = namespace

      raise(InterfaceGettingError, service_name: service_name) unless hostname
      { hostname: @hostname }
    end

    private

    attr_reader :service_name, :namespace

    def hostname
      return @hostname if defined?(@hostname)
      begin
        tries ||= 5 # sometime k8s takes its time to create the ELB
        service = JSON.parse(`kubectl get svc/#{service_name} --namespace=#{namespace} -o json`)
        @hostname ||= service['status']['loadBalancer']['ingress'][0]['hostname']
      rescue
        sleep 1
        retry unless (tries -= 1).zero?
      end
    end
  end
end
