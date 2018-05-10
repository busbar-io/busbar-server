require 'foreman/procfile'

module Builds
  class Compiler
    class VersionControlInfoRetriever
      include Serviceable

      def call(build)
        tag = `git -C #{build.path} describe --tags --always --abbrev=0`.chomp
        commit = `git -C #{build.path} rev-parse HEAD`.chomp

        build.update_attributes(
          tag: tag,
          commit: commit
        )

        build
      end
    end
  end
end
