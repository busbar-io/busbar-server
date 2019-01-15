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
      if node.selector.nil?
        { metadata:     { labels: labels },
          spec:         { containers: containers } }.with_indifferent_access
      else
        { metadata:     { labels: labels },
          spec:         { containers: containers,
                          nodeSelector: { "beta.kubernetes.io/instance-type": \
                                          node.selector \
        } } }.with_indifferent_access
      end
    end

    def labels(prefix = Configurations.kubernetes.label_prefix)
      { "#{prefix}/app" => app_id,
        "#{prefix}/environment" => environment.name,
        "#{prefix}/component" => type }.with_indifferent_access
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
