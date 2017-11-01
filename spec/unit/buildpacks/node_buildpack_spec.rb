require 'rails_helper'

RSpec.describe NodeBuildpack do
  let(:environment)   { Environment.new }
  let(:build) do
    Build.new(environment: environment, log: Log.new(content: ''))
  end

  it_behaves_like Buildpack

  describe '.compile' do
    base_images_registry_url = Configurations.docker.base_images_registry_url

    let(:node_version)         { NodeBuildpack::SUPPORTED.last }
    let(:package_file)         { "#{build.path}/package.json" }
    let(:package_file_content) { %({ "engines": { "node": "#{node_version}" } }) }
    let(:dockerfile_path)      { "#{build.path}/Dockerfile" }

    let(:dockerfile_content) do
      "FROM #{base_images_registry_url}/node:6\n" \
      "ADD package.json /usr/src/app/\n" \
      "RUN env  npm install\n" \
      "ADD . /usr/src/app/\n" \
      "RUN grep -q 'postinstall' package.json && env  npm run postinstall"
    end

    subject { described_class.new.compile }

    before do
      allow_any_instance_of(described_class).to receive(:build).and_return(build)
      allow(IO).to receive(:write).with(dockerfile_path, dockerfile_content).and_return(true)
      allow(File).to receive(:exist?).with(package_file).and_return(true)
      allow(File).to receive(:read).with(package_file).and_return(package_file_content)
    end

    context 'when the node version is supported' do
      it 'injects the Dockerfile using the given node version' do
        expect(IO).to receive(:write).with(dockerfile_path, dockerfile_content)
        subject
      end
    end

    context 'when the node version is not supported' do
      let(:node_version)       { '0.0.0' }

      let(:dockerfile_content) do
        "FROM #{base_images_registry_url}/node:#{NodeBuildpack::LATEST}\n" \
        "ADD package.json /usr/src/app/\n" \
        "RUN env  npm install\n" \
        "ADD . /usr/src/app/\n" \
        "RUN grep -q 'postinstall' package.json && env  npm run postinstall"
      end

      it 'injects the Dockerfile using the latest node version supported' do
        expect(IO).to receive(:write).with(dockerfile_path, dockerfile_content)
        subject
      end
    end

    context 'when the environment has settings defined' do
      let(:settings) { { 'TEST' => 'test' } }
      let(:environment) { Environment.new(settings: settings) }

      let(:dockerfile_content) do
        "FROM #{base_images_registry_url}/node:#{NodeBuildpack::LATEST}\n" \
        "ADD package.json /usr/src/app/\n" \
        "RUN env TEST='test' npm install\n" \
        "ADD . /usr/src/app/\n" \
        "RUN grep -q 'postinstall' package.json && env TEST='test' npm run postinstall"
      end

      it 'injects the Dockerfile so the settings are in the environment when npm is invoked' do
        expect(IO).to receive(:write).with(dockerfile_path, dockerfile_content)
        subject
      end
    end
  end
end
