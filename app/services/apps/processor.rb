module Apps
  class Processor
    include Serviceable

    InvalidBuildpackError = Class.new(StandardError)

    def call(data, options = {})
      @data = data

      options = { name: options['default_env'] } if options['default_env']

      app = App.new(data)

      buildpack_id = BuildpackService.detect(app)

      if data[:buildpack_id].present? && !custom_buildpack? && data[:buildpack_id] != buildpack_id
        raise InvalidBuildpackError
      end

      app.buildpack_id = data[:buildpack_id] || buildpack_id

      app.save!

      EnvironmentService.create(app, options)

      HookService.call(resource: app, action: 'create', value: 'success')

      app
    end

    private

    attr_reader :data

    def custom_buildpack?
      data[:buildpack_id] == 'custom'
    end
  end
end
