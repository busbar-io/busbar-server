require 'rails_helper'

RSpec.describe Builds::Compiler do
  describe '.call' do
    let(:build) do
      instance_double(
        Build,
        path: 'a/path',
        log: log,
        start!: true,
        finish!: true,
        fail!: true
      )
    end

    let(:options) { Hash.new }
    let(:log)     { instance_double(Log) }

    subject { described_class.call(build, options) }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(Builds::Compiler::SourceCodeRetriever).to receive(:call)
      allow(Builds::Compiler::VersionControlInfoRetriever).to receive(:call)
      allow(Builds::Compiler::SlugGenerator).to receive(:call)
      allow(Builds::Compiler::CommandInjector).to receive(:call)
      allow(Builds::Compiler::SlugRegistrar).to receive(:call)
      allow(log).to receive(:append_step)
      allow(log).to receive(:append_error)
    end

    it 'appends a message about setting up the slug directory' do
      expect(build.log).to receive(:append_step)
        .with('Setting Up Slug Directory').once

      subject
    end

    it 'sets up the slug directory' do
      expect(FileUtils).to receive(:mkdir_p).with(File.dirname(build.path))
      subject
    end

    it 'appends a message about retrieving the source code' do
      expect(build.log).to receive(:append_step)
        .with('Retrieving Source Code').once

      subject
    end

    it 'retrieves the source code' do
      expect(Builds::Compiler::SourceCodeRetriever).to receive(:call).with(build)
      subject
    end

    it 'appends a message about retrieving the version control info' do
      expect(build.log).to receive(:append_step)
        .with('Retrieving Version Control Info').once

      subject
    end

    it 'retrieves the version control info' do
      expect(Builds::Compiler::VersionControlInfoRetriever).to receive(:call).with(build)
      subject
    end

    it 'appends a message about generating the slug' do
      expect(build.log).to receive(:append_step)
        .with('Generating Slug').once

      subject
    end

    it 'generates the slug' do
      expect(Builds::Compiler::SlugGenerator).to receive(:call).with(build)
      subject
    end

    it 'appends a message about injecting commands' do
      expect(build.log).to receive(:append_step)
        .with('Injecting Commands').once

      subject
    end

    it 'injects the commands' do
      expect(Builds::Compiler::CommandInjector).to receive(:call).with(build)
      subject
    end

    it "appends a success message to the build's log" do
      expect(build.log).to receive(:append_step)
        .with('Build successful').once

      subject
    end

    it 'deletes the build files' do
      expect(FileUtils).to receive(:rm_rf).with(build.path).once

      subject
    end

    context 'when the build options are set to not register the slug' do
      let(:options) { { register: false } }

      it 'appends a message about skipping the slug regsistration' do
        expect(build.log).to receive(:append_step)
          .with('Skipping build registration').once

        subject
      end

      it 'does not register the slug' do
        expect(Builds::Compiler::SlugRegistrar).not_to receive(:call).with(build)
        subject
      end
    end

    context 'when the build options are set to register the slug' do
      let(:options) { { register: true } }

      it 'appends a message about registering the slug' do
        expect(build.log).to receive(:append_step)
          .with('Registering Slug').once

        subject
      end

      it 'registers the slug' do
        expect(Builds::Compiler::SlugRegistrar).to receive(:call).with(build)
        subject
      end
    end

    context 'when there is an issue with the slug generation' do
      before do
        allow(Builds::Compiler::SlugGenerator).to receive(:call)
          .with(build)
          .and_raise(Builds::Compiler::SlugGenerator::SlugGenerationError)
      end

      it 'changes the build state to broken' do
        expect(build).to receive(:fail!).once

        subject
      end

      it 'appends an error to the build log' do
        expect(build.log).to receive(:append_error)
          .with('This Build/Deploy will be aborted')
          .once

        subject
      end

      it 'appends an error to the build log' do
        expect(build.log).to receive(:append_error)
          .with('This Build/Deploy will be aborted')
          .once

        subject
      end

      it 'returns the build' do
        expect(subject).to eq(build)
      end

      it 'deletes the build files' do
        expect(FileUtils).to receive(:rm_rf).with(build.path).once

        subject
      end

      it 'does not register the slug' do
        expect(Builds::Compiler::SlugRegistrar).to_not receive(:call)

        subject
      end

      it 'does not finish the build' do
        expect(build).to_not receive(:finish!)

        subject
      end

      it 'does not append a success message' do
        expect(build.log).to_not receive(:append_step)
          .with('Build successful')

        subject
      end
    end
  end
end
