class Component
  class Manifest
    include Virtus.model

    attribute :component, Component
    attribute :settings,  Hash
    attribute :timestamp, Integer, default: -> (_p, _a) { Time.zone.now.to_i }

    LIFECYCLE_COMMAND = ['bash', '-c', 'touch /terminate; sleep 20'].freeze
    READINESSPROBE_COMMAND = ['bash', '-c', '! test -f /terminate'].freeze

    %w(environment node command type scale image_url name app_id).each do |attr|
      define_method(attr) do
        return unless component.present?
        component.send(attr)
      end
    end

    def render
      { apiVersion: 'extensions/v1beta1',
        kind:       'Deployment',
        metadata:   spec_metadata,
        spec:       spec }.with_indifferent_access
    end

    private

    def spec_metadata
      { name: name, labels: labels }.with_indifferent_access
    end

    def spec_template
      if Configurations.apps.node_selector.nil?
        { metadata:     { labels: labels,
                          annotations: annotations },
          spec:         { containers: containers } }.with_indifferent_access
      else
        { metadata:     { labels: labels,
                          annotations: annotations },
          spec:         { containers: containers,
                          nodeSelector: { "beta.kubernetes.io/instance-type": \
                                          Configurations.apps.node_selector \
        } } }.with_indifferent_access
      end
    end

    def labels(prefix = Configurations.kubernetes.label_prefix)
      { "#{prefix}/app" => app_id,
        "#{prefix}/environment" => environment.name,
        "#{prefix}/component" => type,
        "#{prefix}/nodetype" => node.id }.with_indifferent_access
    end

    def annotations
      app_string = "[{\"source\":\"#{datadog_logs_source}\",\"service\":\"#{datadog_logs_service}\"}]"
      if web_component?
        web_string = "[{\"source\":\"nginx\",\"service\":\"#{datadog_logs_service}\"}]"
        { "ad.datadoghq.com/#{name}.logs": app_string.to_s, "ad.datadoghq.com/#{name}-nginx.logs": web_string.to_s }.with_indifferent_access
      else
        { "ad.datadoghq.com/#{name}.logs": app_string.to_s }.with_indifferent_access
      end
    end

    def spec
      { replicas: scale,
        strategy: strategy,
        template: spec_template }.with_indifferent_access
    end

    def strategy
      {
        rollingUpdate: {
          maxSurge: transient_instances,
          maxUnavailable: transient_instances
        }
      }
    end

    def app_port
      port = web_port
      port += 10 if web_component?
      port
    end

    def java_options
      settings.fetch('_JAVA_OPTIONS', '-Xmx1280m -Xms1280m').to_s
    end

    def datadog_logs_service
      settings.fetch('DATADOG_LOGS_SERVICE', "#{app_id}-#{type}").to_s
    end

    def datadog_logs_source
      settings.fetch('DATADOG_LOGS_SOURCE', environment.buildpack_id).to_s
    end

    def web_port
      settings.fetch('PORT', 8080).to_i
    end

    def web_component?
      type.include? 'web'
    end

    def transient_instances
      return 1 if Configurations.manifest.unavailable_percentage.nil?

      [
        (scale * (Configurations.manifest.unavailable_percentage.to_f / 100)).ceil,
        1
      ].max
    end

    def initial_delay
      settings.fetch('_INITIAL_DELAY', 5).to_i
    end

    def containers
      cont = []
      cont << AppContainer.new(component: component, settings: settings).render
      cont << WebContainer.new(component: component, settings: settings).render if web_component?
      cont
    end
  end
end
