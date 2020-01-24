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
      aws_login = IO.popen(['$(aws ecr get-login --no-include-email --region', Configurations.aws.region]).read
            raise "it failed!" unless $?.exitstatus == 0
            return aws_login

      cmd = "cd #{path}"\
            " && docker build --build-arg BASE64_MAVEN_SETTINGS=#{base64_maven_settings} --tag=#{image_tag} ."

      CommandExecutorAndLogger.call(cmd, build.log)
    end

    def base64_maven_settings
      Configurations.java.base64_maven_settings
    end

  end
end
