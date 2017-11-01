require 'rails_helper'

RSpec.describe JavaBuildpack do
  let(:environment) { Environment.new }
  let(:build) do
    Build.new(environment: environment, log: Log.new(content: ''))
  end

  it_behaves_like Buildpack

  describe '.compile' do
    base_images_registry_url = Configurations.docker.base_images_registry_url

    let(:java_version)            { JavaBuildpack::SUPPORTED.first }
    let(:properties_file)         { "#{build.path}/system.properties" }
    let(:properties_file_content) { StringIO.new("java.runtime.version=#{java_version}") }
    let(:dockerfile_path)         { "#{build.path}/Dockerfile" }
    let(:dockerfile_content)      { "FROM #{base_images_registry_url}/java:#{java_version}" }

    subject { described_class.new.compile }

    before do
      allow_any_instance_of(described_class).to receive(:path).and_return(build.path)
      allow(IO).to receive(:write).with(dockerfile_path, dockerfile_content).and_return(true)
      allow(File).to receive(:exist?).with(properties_file).and_return(true)
      allow(File).to receive(:open)
        .with(properties_file, anything)
        .and_yield(properties_file_content)
    end

    context 'when the java version is supported' do
      it 'injects the Dockerfile using the given java version' do
        expect(IO).to receive(:write).with(dockerfile_path, dockerfile_content)
        subject
      end
    end

    context 'when the java version is not supported' do
      let(:java_version)       { '0.0.0' }
      let(:dockerfile_content) { "FROM #{base_images_registry_url}/java:#{JavaBuildpack::LATEST}" }

      it 'injects the Dockerfile using the latest java version supported' do
        expect(IO).to receive(:write).with(dockerfile_path, dockerfile_content)
        subject
      end
    end
  end
end
