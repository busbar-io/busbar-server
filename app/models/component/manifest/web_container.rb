class Component
  class Manifest
    class WebContainer < Manifest
      include Virtus.model

      NGINX_COMMAND = ['bash', '-c', '/run_proxy.sh'].freeze
      IMAGE = "#{Configurations.docker.base_images_registry_url}/nginx-frontend:latest".freeze

      def render
        { name:            "#{name}-nginx",
          image:           IMAGE,
          imagePullPolicy: 'Always',
          env:             [{ name: 'FRONTEND_PORT', value: web_port.to_s },
                            { name: 'BACKEND_PORT', value: app_port.to_s }],
          command:         NGINX_COMMAND,
          resources:       web_resources,
          ports:           [{ containerPort: web_port }],
          lifecycle:       { preStop: { exec: { command: LIFECYCLE_COMMAND } } },
          readinessProbe:  { exec: { command: READINESSPROBE_COMMAND },
                             failureThreshold: 1,
                             initialDelaySeconds: initial_delay,
                             periodSeconds: 10,
                             successThreshold: 1,
                             timeoutSeconds: 10 } }
      end

      private

      def web_resources
        { limits: { cpu: '4', memory: '128Mi' },
          requests: { cpu: '10m', memory: '128Mi' } }.with_indifferent_access
      end
    end
  end
end
