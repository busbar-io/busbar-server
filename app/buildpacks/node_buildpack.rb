class NodeBuildpack
  include Buildpack

  LATEST    = '12'.freeze # 12 is the LTS version
  SUPPORTED = %w(5 6 8 10 12).freeze
  TEMPLATE  = [
    'FROM <%= base_images_registry_url %>/node:<%= node_version %>',
    'ADD package.json /usr/src/app/',
    'RUN env <%= build_env %> npm install',
    'ADD . /usr/src/app/',
    'RUN grep -q \'postinstall\' package.json && env <%= build_env %> npm run postinstall'
  ].join("\n").freeze

  def compile
    inject_dockerfile
  end

  private

  def base_images_registry_url
    Configurations.docker.base_images_registry_url
  end

  def node_version
    packages_file = [path, 'package.json'].join('/')
    return LATEST unless File.exist?(packages_file)

    packages = JSON.parse(File.read(packages_file))
    version  = packages.dig('engines', 'node')
    return LATEST unless version.present?

    # Not really the best way to parse this version, see https://docs.npmjs.com/misc/semver
    major_version = version.match(/\d+/).to_a.first
    SUPPORTED.include?(major_version) ? major_version : LATEST
  end

  def build_env
    @build_env ||= build.environment.settings.map { |k, v| "#{k.upcase}='#{v}'" }.join(' ')
  end

  def inject_dockerfile
    dockerfile_content = ERB.new(TEMPLATE).result(binding)
    IO.write(dockerfile_path, dockerfile_content)
  end
end
