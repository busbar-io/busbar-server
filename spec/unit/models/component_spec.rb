require 'rails_helper'

RSpec.describe Component, type: :model do
  subject do
    Component.new(
      environment: environment,
      command: 'rails s',
      type: 'worker',
      image_url: 'some_url'
    )
  end

  let(:environment) do
    Environment.new(
      id: 'some_environment',
      app_id: 'some_app',
      name: 'staging'
    )
  end

  it { is_expected.to be_valid }

  it "isn't valid without a environment_id" do
    subject.environment_id = nil
    expect(subject).not_to be_valid
  end

  it "isn't valid without a command" do
    subject.command = nil
    expect(subject).not_to be_valid
  end

  it "isn't valid without a type" do
    subject.type = nil
    expect(subject).not_to be_valid
  end

  it "isn't valid without a image_url" do
    subject.image_url = nil
    expect(subject).not_to be_valid
  end

  it "sets the default node_id to '1x.standard'" do
    expect(subject.node_id).to eq('1x.standard')
  end

  it 'sets the default scale to 0' do
    expect(subject.scale).to eq(0)
  end

  it "sets the default state to 'new'" do
    expect(subject.state).to eq('new')
  end

  describe '#name' do
    it 'returns the environment_id combined with the type' do
      expect(subject.name).to eq('some_app-some_environment-worker')
    end
  end

  describe '#node' do
    before do
      allow(Node).to receive(:find).with(subject.node_id).and_return(node)
    end

    let(:node) { double(:node) }

    context 'on the first time' do
      it 'retrives the node based on the node id' do
        expect(subject.node).to eq(node)
      end
    end

    context 'on the second time onwards' do
      before do
        subject.node
      end

      it 'uses the node stored on the instance' do
        expect(Node).to_not receive(:find)

        expect(subject.node).to eq(node)
      end
    end
  end

  describe '#settings' do
    context 'when the environment is present' do
      before do
        allow(environment).to receive_message_chain(:latest_deployment, :settings)
          .and_return(some_setting: 'some_value')
      end

      it 'returns nil' do
        expect(subject.settings).to eq(environment.latest_deployment.settings)
      end
    end

    context 'when the environment is blank' do
      before do
        subject.environment = nil
      end

      it 'returns nil' do
        expect(subject.settings).to be_nil
      end
    end
  end

  describe '#selector' do
    context 'when a prefix is not provided' do
      it 'used the default config value with the environment id and type' do
        expect(subject.selector).to eq(
          "#{Configurations.kubernetes.label_prefix}/environment=#{subject.environment_id}," \
          "#{Configurations.kubernetes.label_prefix}/component=#{subject.type}"
        )
      end
    end

    context 'when a prefix is provided' do
      it 'used the provided value with the environment id and type' do
        expect(subject.selector('custom_prefix')).to eq(
          "custom_prefix/environment=#{subject.environment_id}," \
          "custom_prefix/component=#{subject.type}"
        )
      end
    end
  end

  describe '#manifest' do
    before do
      allow(Component::Manifest).to receive(:new)
        .with(component: subject, settings: subject.settings)
        .and_return(manifest)
    end

    let(:manifest) { double(:manifest) }

    context 'on the first time' do
      it 'creates a new manifest' do
        expect(Component::Manifest).to receive(:new)
          .with(component: subject, settings: subject.settings).once

        subject.manifest
      end

      it 'returns a new manifest' do
        expect(subject.manifest).to eq(manifest)
      end
    end

    context 'on the second time onwards' do
      before do
        subject.manifest
      end

      it 'uses the manifest stored on the instance' do
        expect(Component::Manifest).to_not receive(:new)

        expect(subject.manifest).to eq(manifest)
      end
    end
  end

  describe '#manifest_file' do
    before do
      allow(IO).to receive(:write).with(manifest_file.path, manifest.render.to_json)

      allow(Tempfile).to receive(:new)
        .with(['component', subject.id].join('-'))
        .and_return(manifest_file)

      allow(subject).to receive(:manifest).and_return(manifest)
    end

    let(:manifest_file) { instance_double(Tempfile, path: 'some/path') }
    let(:manifest) do
      double(:manifest, render: { some_manifest_data: 'value' })
    end

    context 'on the first time' do
      it 'creates a new manifest_file' do
        expect(Tempfile).to receive(:new).with("component-#{subject.id}")

        subject.manifest_file
      end

      it 'writes the rendered manifest on the created manifest file' do
        expect(IO).to receive(:write).with(manifest_file.path, manifest.render.to_json)

        subject.manifest_file
      end

      it 'returns a new manifest' do
        expect(subject.manifest_file).to eq(manifest_file)
      end
    end

    context 'on the second time onwards' do
      before do
        subject.manifest_file
      end

      it 'uses the manifest_file stored on the instance' do
        expect(Tempfile).to_not receive(:new)
        expect(IO).to_not receive(:write)

        expect(subject.manifest_file).to eq(manifest_file)
      end
    end
  end

  describe '#namespace' do
    before do
      allow(environment).to receive(:namespace).and_return('staging')
    end

    it "returns the component's environment namespace" do
      expect(subject.namespace).to eq('staging')
    end
  end

  describe '#environment_name' do
    before do
      allow(environment).to receive(:name).and_return('staging')
    end

    it "returns the component's environment name" do
      expect(subject.environment_name).to eq('staging')
    end
  end

  describe '#log' do
    before do
      allow(environment).to receive(:log).and_return(some_log)
    end

    let(:some_log) { instance_double(Log) }

    it 'returns the environment log' do
      expect(subject.log).to eq(some_log)
    end
  end
end
