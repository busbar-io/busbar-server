module Buildpacks
  class Detector
    include Serviceable

    InvalidBuildpack = Class.new(StandardError)

    SIGNATURES = {
      'ruby' => ['Gemfile'],
      'node' => ['package.json'],
      'java' => ['build.gradle', 'pom.xml', 'build.sbt'],
      'custom' => ['Dockerfile']
    }.freeze

    def call(app)
      path = source_code_path_for(app)
      deployment_key_file = Configurations.git.deployment_key_file

      FileUtils.mkdir_p(File.dirname(path))

      CommandExecutorAndLogger.call(
        "GIT_SSH_COMMAND='ssh -i #{deployment_key_file}' git clone --progress #{app.repository} --branch #{app.default_branch} #{path}", # rubocop:disable Metrics/LineLength
        nil
      )

      buildpack_id = SIGNATURES.select do |_, files|
        files.any? { |file| File.exist?([path, file].join('/')) }
      end.keys.first

      FileUtils.rm_rf(path)

      buildpack_id
    end

    private

    def source_code_path_for(app)
      [base_path, app.id.to_s].join('/')
    end

    def base_path
      '/tmp/repository'
    end
  end
end
