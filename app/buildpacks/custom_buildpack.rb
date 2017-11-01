class CustomBuildpack
  include Buildpack

  ERROR_MESSAGE = 'Missing dockerfile at the root of the application source code'.freeze

  def compile
    log_missing_docker_error unless File.exist?(dockerfile_path)
  end

  private

  def log_missing_docker_error
    build.log.append_error(ERROR_MESSAGE)

    raise(CompileError, ERROR_MESSAGE)
  end
end
