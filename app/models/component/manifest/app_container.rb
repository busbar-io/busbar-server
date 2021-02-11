class Component
  class Manifest
    class AppContainer < Manifest
      include Virtus.model

      def render
        { name:            name,
          image:           image_url,
          imagePullPolicy: 'Always',
          env:             environment_settings,
          command:         ['bash', '-c', command],
          resources:       app_resources,
          ports:           [{ containerPort: app_port }],
          lifecycle:       { preStop: { exec: { command: LIFECYCLE_COMMAND } } },
          readinessProbe:  { exec: { command: READINESSPROBE_COMMAND },
                             failureThreshold: 1,
                             initialDelaySeconds: initial_delay,
                             periodSeconds: 10,
                             successThreshold: 1,
                             timeoutSeconds: 10 } }
      end

      private

      def app_resources
        maximal_resource_data = { cpu: node.cpu,
                                  memory: node.memory }
        guaranteed_resource_data = { cpu: node.guaranteed_cpu,
                                     memory: node.memory }
        { limits: maximal_resource_data,
          requests: guaranteed_resource_data }.with_indifferent_access
      end

      def environment_settings
        env = settings.except('PORT')
                      .map { |k, v| { name: k.to_s, value: v.to_s }.with_indifferent_access }
        env << { name: '_JAVA_OPTIONS', value: java_options.to_s }.with_indifferent_access
        env << { name: '_BUSBAR_BUILD_TIME', value: timestamp.to_s }.with_indifferent_access
        env << { name: 'PORT', value: app_port.to_s }.with_indifferent_access
        env << { name: 'DD_AGENT_HOST', valueFrom: { fieldRef: { fieldPath: 'status.hostIP'}}}.with_indifferent_access
        env << { name: 'DD_ENV', value: environment.name }.with_indifferent_access
        env << { name: 'DD_SERVICE', value: app_id }.with_indifferent_access
        env << { name: 'DD_VERSION', value: environment.branch }.with_indifferent_access
        env << { name: 'BUSBAR_APP', value: app_id }.with_indifferent_access
        env << { name: 'BUSBAR_ENV', value: environment.name }.with_indifferent_access
        env << { name: 'BUSBAR_COMPONENT', value: type }.with_indifferent_access
        env << { name: 'BUSBAR_NODETYPE', value: node.id }.with_indifferent_access
        env << { name: 'BUSBAR_BUILDPACK', value: environment.buildpack_id }.with_indifferent_access
        env
      end
    end
  end
end
