module Deployments
  class Processor
    include Serviceable

    def call(deployment, options = {})
      @deployment = deployment
      @options = options.with_indifferent_access

      build
      launch
      finish
      notify_creation

      deployment
    rescue BuildInjector::BuildInjectionError
      deployment.fail!
      notify_failure

      deployment
    end

    private

    attr_reader :deployment, :options

    def build
      return unless deployment.may_start_building?

      deployment.start_building!
      BuildInjector.call(deployment)
      deployment.finish_building!
    end

    def launch
      deployment.launch!
      Launcher.call(deployment, options)
    end

    def finish
      deployment.finish!
    end

    def notify_creation
      HookService.call(resource: deployment, action: 'finish', value: 'success') if should_notify?
    end

    def notify_failure
      HookService.call(resource: deployment, action: 'build', value: 'fail') if should_notify?
    end

    def should_notify?
      options.fetch(:notifiy, false)
    end
  end
end
