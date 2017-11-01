module Settings
  class Finder
    include Serviceable

    def call(environment, data = {})
      @environment = environment
      @data        = data.with_indifferent_access
      return unless value_set?

      Setting.new(key: key, value: value)
    end

    private

    attr_reader :environment, :key, :data

    def settings
      @settings ||= environment.settings.with_indifferent_access
    end

    def key
      data.fetch('key')
    end

    def value_set?
      settings.key?(key)
    end

    def value
      settings.fetch(key, nil)
    end
  end
end
