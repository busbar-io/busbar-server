module Settings
  class Upserter
    include Serviceable

    def call(environment, data = {}, deployment_params = {})
      @environment = environment
      @data = data.with_indifferent_access
      @deployment_params = deployment_params.with_indifferent_access
      return setting unless setting.valid? && upsert_environment

      deploy if @deployment_params[:deploy]
      setting
    end

    private

    attr_reader :environment, :setting, :data

    def setting
      @setting ||= Setting.new(key: data['key'], value: data['value'])
    end

    def upsert_environment
      operation = SettingUpserter.call(environment, "settings.#{setting.key}" => setting.value)

      setting.errors.add(:base, 'Failed to upsert setting') unless operation

      operation
    end

    def deploy
      DeploymentService.create(environment, {}, build: false)
    end
  end
end
