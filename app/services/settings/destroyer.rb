module Settings
  class Destroyer
    include Serviceable

    def call(environment, setting)
      @environment = environment
      @setting = setting

      return unless unset_setting

      notify_setting_destruction
      deploy
    end

    private

    attr_reader :environment, :setting

    def unset_setting
      environment.update_attributes(settings: new_settings) if environment.settings != new_settings
    end

    def new_settings
      environment.settings.except(setting.key)
    end

    def notify_setting_destruction
      HookService.call(
        resource: environment,
        action: 'unset',
        value: { setting.key => setting.value }
      )
    end

    def deploy
      DeploymentService.create(environment, {}, build: false)
    end
  end
end
