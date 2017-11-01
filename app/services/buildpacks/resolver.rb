module Buildpacks
  class Resolver
    include Serviceable

    InvalidBuildpack = Class.new(StandardError)

    BUILDPACKS = {}.freeze

    def call(buildpack_id)
      @buildpack_id = buildpack_id

      buildpack
    end

    private

    attr_reader :buildpack_id

    def buildpack
      return @buildpack if defined?(@buildpack)

      klass = BUILDPACKS.fetch(buildpack_id, autodetect)
      raise(InvalidBuildpack, buildpack_id) unless klass.present?

      @buildpack = klass.new
      @buildpack
    end

    def autodetect
      [buildpack_id.classify, 'Buildpack'].join.safe_constantize
    end
  end
end
