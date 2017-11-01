module Builds
  class Compiler
    class SourceCodeRetriever
      include Serviceable
      extend Forwardable

      SourceCodeRetrievalError = Class.new(StandardError)

      def call(build)
        @build = build
        raise(SourceCodeRetrievalError, build.id) unless retrieve_source_code

        build
      end

      private

      attr_reader :build

      def_delegators :build, :repository, :branch, :path

      def retrieve_source_code
        deployment_key_file = Configurations.git.deployment_key_file

        CommandExecutorAndLogger.call(
          "GIT_SSH_COMMAND='ssh -i #{deployment_key_file}' git clone --progress #{repository} --branch #{branch} #{path}", # rubocop:disable Metrics/LineLength
          build.log
        )
      end
    end
  end
end
