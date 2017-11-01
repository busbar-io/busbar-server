module Builds
  class Compiler
    class SlugGenerator
      include Serviceable
      extend Forwardable

      SlugGenerationError = Class.new(StandardError)

      def call(build)
        @build = build
        raise(SlugGenerationError, build.id) unless buildpack.call(build)

        build
      rescue Buildpack::CompileError
        raise(SlugGenerationError, build.id)
      end

      private

      attr_reader :build

      def_delegators :build, :buildpack
    end
  end
end
