module Builds
  class Compiler
    include Serviceable
    extend Forwardable

    def call(build, options = {})
      @build   = build
      @options = options.with_indifferent_access

      build.start!

      setup_slug_directory
      retrieve_source_code
      retrieve_version_control_info
      inject_commands
      generate_slug
      register_slug
      append_success_message

      build.finish!

      build
    rescue Builds::Compiler::SlugGenerator::SlugGenerationError
      build.fail!
      build.log.append_error('This Build/Deploy will be aborted')
      build
    ensure
      FileUtils.rm_rf(build.path)
    end

    private

    attr_reader :build, :options

    def setup_slug_directory
      build.log.append_step('Setting Up Slug Directory')

      FileUtils.mkdir_p(File.dirname(build.path))
    end

    def retrieve_source_code
      build.log.append_step('Retrieving Source Code')

      SourceCodeRetriever.call(build)
    end

    def retrieve_version_control_info
      build.log.append_step('Retrieving Version Control Info')

      VersionControlInfoRetriever.call(build)
    end

    def generate_slug
      build.log.append_step('Generating Slug')

      SlugGenerator.call(build)
    end

    def inject_commands
      build.log.append_step('Injecting Commands')

      CommandInjector.call(build)
    end

    def register_slug
      if options[:register] == false
        build.log.append_step('Skipping build registration')

        return
      end

      build.log.append_step('Registering Slug')

      SlugRegistrar.call(build)
    end

    def append_success_message
      build.log.append_step('Build successful')
    end
  end
end
