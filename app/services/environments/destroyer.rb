module Environments
  class Destroyer
    include Serviceable

    def call(environment)
      EnvironmentDestroyProcessing.perform_async(environment.id.to_s)
    end
  end
end
