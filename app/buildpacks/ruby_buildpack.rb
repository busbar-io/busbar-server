class RubyBuildpack
  include Buildpack

  TEMPLATE = [
    'FROM <%= base_images_registry_url %>/ruby:<%= ruby_version %>'
  ].join("\n").freeze


  def compile
    inject_dockerfile
  end

  private

  def base_images_registry_url
    Configurations.docker.base_images_registry_url
  end

  def ruby_version
    dotfile_path = [path, '.ruby-version'].join('/')
    return latest_version unless File.exist?(dotfile_path)

    v = IO.read(dotfile_path).strip
    supported_versions.include?(v) ? v : latest_version
  end

  def inject_dockerfile
    dockerfile_content = ERB.new(TEMPLATE).result(binding)
    IO.write(dockerfile_path, dockerfile_content)
  end

  def latest_version
    Configurations.buildpacks.ruby.latest_version
  end

  def supported_versions
    Configurations.buildpacks.ruby.supported_versions
  end
end
