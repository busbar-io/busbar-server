module PublicInterfaces
  class Destroyer
    include Serviceable

    DestructionError = Class.new(StandardError)

    def call(environment)
      if environment.public?
        raise(DestructionError) unless system('kubectl delete svc ' \
                                              "#{environment.app_id}-#{environment.id}-public "\
                                              "--namespace=#{environment.namespace}")
      end
    end
  end
end
