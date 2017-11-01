module Builds
  class Creator
    include Serviceable

    def call(environment, data = {}, options = {})
      @environment = environment
      @data        = data.with_indifferent_access
      @options     = options.with_indifferent_access
      return build unless save_build

      compile
      build
    end

    private

    attr_reader :environment, :data, :options

    def build
      return @build if defined?(@build)
      @build = BuildFactory.call(environment, data)
    end

    def compile
      return if options[:compile] == false
      BuildService.compile(build, options)
    end

    def save_build
      build.valid? && build.save && build.log.save
    end
  end
end
