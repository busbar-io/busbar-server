module Deployments
  class Processor
    class Launcher
      include Serviceable
      extend Forwardable

      DeploymentLaunchError = Class.new(StandardError)

      def call(deployment, options = {})
        @deployment = deployment
        @options = options.with_indifferent_access

        unless launch
          build.log.append_step('Lauching failed')

          raise(DeploymentLaunchError, deployment.id)
        end

        deployment
      end

      private

      attr_reader :deployment, :options

      def_delegators :deployment, :environment, :build, :settings
      def_delegators :build,      :commands, :image_url

      def launch
        return unless build.present?

        upsert_components && uninstall_deprecated_components
      end

      def upsert_components
        commands.each do |type, command|
          component_data = component_data_for(type, command)

          build.log.append_step("Upserting #{type} component")

          ComponentService.upsert(environment, component_data, options)
        end
      end

      def uninstall_deprecated_components
        build.log.append_step('Deprecating old components')

        deprecated_components.each do |component|
          ComponentService.destroy(component)
        end
      end

      def component_data_for(type, command)
        { 'environment_id' => environment.id.to_s,
          'image_url' => image_url,
          'settings' => settings,
          'command' => command,
          'type' => type,
          'node_id' => environment.default_node_id }
      end

      def deprecated_components
        defined_types = commands.keys

        Component.where(environment_id: environment.id)
                 .nin(type: defined_types)
                 .to_a
      end
    end
  end
end
