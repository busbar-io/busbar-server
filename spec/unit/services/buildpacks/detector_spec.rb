require 'rails_helper'

RSpec.describe Buildpacks::Detector do
  describe '#source_code_path_for', :private do
    let!(:app) do
      App.create(
        _id: 'some_app',
        repository: 'git@example.com:EXAMPLE/app.git'
      )
    end

    let(:detector) { Buildpacks::Detector.new }

    subject { detector.source_code_path_for(app) }

    it 'check source code checkout path' do
      expect(subject).to eq '/tmp/repository/some_app'
    end
  end

  describe '.call' do
    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(FileUtils).to receive(:rm_rf)
      allow(Builds::Compiler::SourceCodeRetriever).to receive(:call)
      allow(CommandExecutorAndLogger).to receive(:call).with(command, nil).and_return(true)
      allow_any_instance_of(described_class).to \
        receive(:source_code_path_for).with(app).and_return(path)
    end

    let(:command) do
      deployment_key_file = Configurations.git.deployment_key_file

      "GIT_SSH_COMMAND='ssh -i #{deployment_key_file}' git clone --progress #{app.repository} --branch #{app.default_branch} #{path}" # rubocop:disable Metrics/LineLength
    end

    let!(:app) do
      App.create(
        _id: 'some_app',
        repository: 'git@example.com:EXAMPLE/app.git'
      )
    end

    subject { described_class.call(app) }

    context 'with a valid application buildpack' do
      let(:path) { Rails.root.join('spec/fixtures/buildpacks/ruby_app').to_s }

      it 'sets up the directory' do
        expect(FileUtils).to receive(:mkdir_p).with(File.dirname(path))
        subject
      end
    end

    describe 'buildpacks' do
      context 'with a ruby application' do
        let(:path) { Rails.root.join('spec/fixtures/buildpacks/ruby_app').to_s }

        it 'returns ruby buildpack' do
          expect(subject).to eq 'ruby'
        end
      end

      context 'with a node application' do
        let(:path) { Rails.root.join('spec/fixtures/buildpacks/node_app').to_s }

        it 'returns node buildpack' do
          expect(subject).to eq 'node'
        end
      end

      context 'with a java application' do
        let(:path) { Rails.root.join('spec/fixtures/buildpacks/java_app').to_s }

        it 'returns java buildpack' do
          expect(subject).to eq 'java'
        end
      end

      context 'with a custom buildpack' do
        let(:path) { Rails.root.join('spec/fixtures/buildpacks/custom_app').to_s }

        it 'returns custom buildpack' do
          expect(subject).to eq 'custom'
        end
      end

      context 'with a no registered buildpack' do
        let(:path) { Rails.root.join('spec/fixtures/buildpacks/invalid_app').to_s }

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
    end
  end
end
