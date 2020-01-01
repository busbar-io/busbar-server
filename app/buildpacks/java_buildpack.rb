class JavaBuildpack
  include Buildpack

  LATEST    = '1.8'.freeze
  SUPPORTED = %w(1.8).freeze
  TEMPLATE  = [ 'FROM <%= base_images_registry_url %>/java:<%= java_version %>' ].join("\n").freeze

  def compile
    inject_dockerfile
  end

  private

  def base_images_registry_url
    Configurations.docker.base_images_registry_url
  end

  def java_version
    properties_file = [path, 'system.properties'].join('/')
    return LATEST unless File.exist?(properties_file)

    properties = JavaProperties.load(properties_file).to_h.with_indifferent_access
    version    = properties['java.runtime.version']
    return LATEST unless version.present?

    SUPPORTED.include?(version) ? version : LATEST
  end

  def inject_dockerfile
    dockerfile_content = ERB.new(TEMPLATE).result(binding)
    IO.write(dockerfile_path, dockerfile_content)
  end
end
