module Deployments
  class Processor
    class BuildInjector
      include Serviceable
      extend Forwardable

      BuildInjectionError = Class.new(StandardError)

      def call(deployment)
        @deployment = deployment

        raise(BuildInjectionError, deployment.id) unless inject_build

        deployment
      end

      private

      attr_reader :deployment

      def_delegators :deployment, :environment, :buildpack_id, :branch

      def build
        return @build if defined?(@build)
        @build = BuildService.create(environment, build_data)
      end

      def build_data
        { buildpack_id: buildpack_id, branch: branch }.compact
      end

      def inject_build
        return if build.blank?
        deployment.build = build
        deployment.save && build.state != 'broken'
      end
    end
  end
end
