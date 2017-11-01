require 'rails_helper'

RSpec.describe RubyBuildpack do
  let(:environment) { Environment.new }
  let(:build) do
    Build.new(environment: environment, log: Log.new(content: ''))
  end

  it_behaves_like Buildpack

  describe '.compile' do
    base_images_registry_url = Configurations.docker.base_images_registry_url

    let(:ruby_version)      { Configurations.buildpacks.ruby.supported_versions.first }
    let(:ruby_version_path) { "#{build.path}/.ruby-version" }
    let(:dockerfile_path)   { "#{build.path}/Dockerfile" }

    let(:dockerfile_content) { "FROM #{base_images_registry_url}/ruby:#{ruby_version}" }

    subject { described_class.new.compile }

    before do
      allow_any_instance_of(described_class).to receive(:path).and_return(build.path)
      allow(File).to receive(:exist?).with(ruby_version_path).and_return(true)
      allow(IO).to receive(:read).with(ruby_version_path).and_return(ruby_version)
      allow(IO).to receive(:write).with(dockerfile_path, dockerfile_content).and_return(true)
    end

    context 'when the ruby version is supported' do
      it 'injects the Dockerfile using the given ruby version' do
        expect(IO).to receive(:write).with(dockerfile_path, dockerfile_content)
        subject
      end
    end

    context 'when the ruby version is not supported' do
      let(:ruby_version)       { '0.0.0' }
      let(:latest_version)     { Configurations.buildpacks.ruby.latest_version }
      let(:dockerfile_content) { "FROM #{base_images_registry_url}/ruby:#{latest_version}" }

      it 'injects the Dockerfile using the latest ruby version supported' do
        expect(IO).to receive(:write).with(dockerfile_path, dockerfile_content)
        subject
      end
    end
  end
end
