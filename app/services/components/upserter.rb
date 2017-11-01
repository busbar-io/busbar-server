module Components
  class Upserter
    include Serviceable

    def call(environment, data = {}, options = {})
      @environment = environment
      @data = data.with_indifferent_access
      @options = options.with_indifferent_access

      return if environment.blank? || type.blank?

      return component unless component.valid? &&
                              component.save &&
                              install

      component
    end

    private

    attr_reader :environment, :data, :options

    def type
      data.fetch('type', nil)
    end

    def resize_components
      options.fetch('resize_components', false)
    end

    def component
      return @component if defined?(@component)

      @component = fetch_component

      @component.assign_attributes(data)
      @component
    end

    def install
      ComponentService.install(component)
    end

    def fetch_component
      component = Component.find_by(environment_id: environment.id, type: type)

      if component.node_id != @environment.default_node_id && !resize_components
        data.delete(:node_id)
      end

      component
    rescue Mongoid::Errors::DocumentNotFound
      Component.new(environment_id: environment.id, type: type)
    end
  end
end
