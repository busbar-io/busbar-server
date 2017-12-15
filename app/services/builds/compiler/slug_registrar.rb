module Builds
  class Compiler
    class SlugRegistrar
      include Serviceable
      extend Forwardable

      SlugRegistrationError = Class.new(StandardError)

      def call(build)
        @build = build
        raise(SlugRegistrationError, build.id) unless register_image

        build
      end

      private

      attr_reader :build

      def_delegators :build, :image_tag, :image_url

      def register_image
        cmd = "docker tag #{image_tag} #{image_url}"\
              " && docker push #{image_url}"

        CommandExecutorAndLogger.call(cmd, build.log)
      end
    end
  end
end
