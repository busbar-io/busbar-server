module Settings
  class CollectionFinder
    include Serviceable

    def call(environment)
      @environment = environment

      environment.settings.map do |k, v|
        Setting.new(key: k, value: v)
      end
    end
  end
end
