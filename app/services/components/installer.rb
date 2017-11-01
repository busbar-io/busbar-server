module Components
  class Installer
    include Serviceable
    extend Forwardable

    ComponentInstallationError = Class.new(StandardError)

    def call(component)
      @component = component

      component.log.append_step('Installing Component')

      install_component

      component
    end

    private

    attr_reader :component

    def_delegators :component, :manifest_file, :namespace

    def install_component
      tries ||= 3
      cmd    = "kubectl apply -f #{manifest_file.path} --namespace=#{namespace}"
      result = CommandExecutorAndLogger.call(cmd, component.log)

      raise(ComponentInstallationError, component_id: component.id,
                                        cmd:          cmd,
                                        result:       result) unless result
    rescue ComponentInstallationError
      retry unless (tries -= 1).zero?

      component.log.append_step('Error while installing component')

      raise

    ensure
      component.install! if component.may_install?
    end
  end
end
