module Buildpack
  extend ActiveSupport::Concern

  CompileError = Class.new(StandardError)

  included do
    include Serviceable
    extend Forwardable

    def call(build)
      @build = build

      compile

      build_image
    end

    protected

    attr_reader :build

    private

    def_delegators :build, :path, :app_id, :image_tag

    def compile
      raise NotImplementedError
    end

    def dockerfile_path
      [path, 'Dockerfile'].join('/')
    end

    def build_image
      cmd = "cd #{path}"\
            " && docker build --build-arg base64_maven_settings=${BASE64_MAVEN_SETTINGS} --tag=#{image_tag} ."

      CommandExecutorAndLogger.call(cmd, build.log)
    end
  end
end
