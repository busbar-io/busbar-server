require 'foreman/procfile'

module Builds
  class Compiler
    class CommandInjector
      include Serviceable
      extend Forwardable

      CommandInjectionError = Class.new(StandardError)

      def call(build)
        @build = build
        raise(CommandInjectionError, build.id) unless inject_commands

        build
      end

      private

      attr_reader :build

      def_delegators :build, :path

      def procfile_path
        [path, 'Procfile'].join('/')
      end

      def procfile
        @procfile ||= Foreman::Procfile.new(procfile_path)
      end

      def commands
        return @commands if defined?(@commands)

        @commands = {}

        procfile.entries do |name, command|
          @commands[name] = command
        end

        @commands
      end

      def inject_commands
        return if commands.blank?
        build.update_attributes(commands: commands)
      end
    end
  end
end
