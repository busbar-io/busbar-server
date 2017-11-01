module PrivateInterfaces
  class Destroyer
    include Serviceable

    DestructionError = Class.new(StandardError)

    def call(environment)
      raise(DestructionError) unless system('kubectl delete svc ' \
                                            "#{environment.app_id}-#{environment.name}-private "\
                                            "--namespace=#{environment.namespace}")
    end
  end
end
