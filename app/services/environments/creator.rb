module Environments
  class Creator
    include Serviceable

    def call(app, data = {})
      @data = data.with_indifferent_access
      @app = app

      return environment unless environment.save

      schedule_processing

      environment
    end

    private

    attr_reader :data, :app

    def environment
      @environment ||= EnvironmentFactory.call(data: data, app: app)
    end

    def schedule_processing
      EnvironmentProcessing.perform_async(environment.id)
    end
  end
end
