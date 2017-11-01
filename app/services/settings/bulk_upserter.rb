module Settings
  class BulkUpserter
    include Serviceable

    def call(environment, data = {}, deployment_params = {})
      @environment = environment
      @data = data.with_indifferent_access
      @deployment_params = deployment_params.with_indifferent_access

      return settings unless settings.all?(&:valid?) && upsert_environment.all?

      HookService.call(resource: environment, action: 'set', value: data)

      deploy if @deployment_params[:deploy]
      settings
    end

    private

    attr_reader :environment, :setting, :data

    def settings
      @settings ||= set_settings
    end

    def set_settings
      @data.map do |key, value|
        Setting.new(key: key, value: value)
      end
    end

    def upsert_environment
      update_query = settings.each_with_object({}) do |setting, base_hash|
        base_hash["settings.#{setting.key}"] = setting.value
      end

      Settings::SettingUpserter.call(environment, update_query)

      settings
    end

    def deploy
      DeploymentService.create(environment, {}, build: false)
    end
  end
end
