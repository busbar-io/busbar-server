class CommandExecutorAndLogger
  include Serviceable

  def call(command, loggable = nil)
    command_log, exit_status = Open3.capture2e(command)

    loggable.append(command_log) if loggable

    exit_status.success?
  end
end
