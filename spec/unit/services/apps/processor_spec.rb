require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Apps::Processor do
  before do
    allow(EnvironmentService).to receive(:create)
    allow(HookService).to receive(:call).with(resource: app, action: 'create', value: 'success')
  end

  let(:data) do
    {
      id: 'some_app',
      repository: 'git@github.com:PaeDae/busbar.git',
      default_branch: 'master'
    }
  end
  let(:app) do
    App.new(
      id: 'some_app',
      repository: 'git@github.com:PaeDae/busbar.git',
      default_branch: 'master'
    )
  end
  let(:buildpack_id) { 'ruby' }

  after do
    app.destroy
  end

  describe '.call' do
    context 'when buildpack_id is present is valid' do
      it 'returns the app saved with the given buildpack_id' do
        allow(BuildpackService).to receive(:detect).and_return(buildpack_id)

        app = described_class.call(data.merge(buildpack_id: buildpack_id))
        expect(app.buildpack_id).to eq buildpack_id
      end
    end

    context 'with a custom buildpack_id' do
      context 'passing via data params' do
        it 'saves the app with custom' do
          allow(BuildpackService).to receive(:detect).and_return(buildpack_id)

          app = described_class.call(data.merge(buildpack_id: 'custom'))

          expect(app.buildpack_id).to eq 'custom'
        end
      end

      context 'with any data params' do
        it 'saves the app with the buildpack_id' do
          allow(BuildpackService).to receive(:detect).and_return(buildpack_id)

          app = described_class.call(data)

          expect(app.buildpack_id).to eq buildpack_id
        end
      end
    end

    context 'when the buildpack_id is different from the app' do
      subject do
        described_class.call(data.merge(buildpack_id: 'java'))
      end

      it 'not create the app' do
        allow(BuildpackService).to receive(:detect).and_return(buildpack_id)

        expect { subject }.to raise_error(Apps::Processor::InvalidBuildpackError)
      end
    end

    context 'without buildpack_id' do
      before do
        allow(App).to receive(:new).and_return(app)
        allow(BuildpackService).to receive(:detect).with(app).and_return(buildpack_id)
      end

      context 'when the options params is not given' do
        subject { described_class.call(data) }

        it 'creates a default develop environment for the given app' do
          expect(EnvironmentService).to receive(:create).with(app, {})

          subject
        end

        it 'creates a notification about the app creation' do
          expect(HookService).to receive(:call)
            .with(resource: app, action: 'create', value: 'success').once

          subject
        end

        it 'returns the persisted app' do
          expect(subject.persisted?).to eq true
        end
      end

      context 'when the options params is given' do
        let(:options) { { 'default_env' => 'staging' } }

        subject { described_class.call(data, options) }

        context 'with the default_env key set' do
          it 'creates an environment for the given app with the default_env name' do
            expect(EnvironmentService).to receive(:create).with(app, name: options['default_env'])

            subject
          end

          it 'creates a notification about the app creation' do
            expect(HookService).to receive(:call)
              .with(resource: app, action: 'create', value: 'success')

            subject
          end
        end

        context 'with the default_env key not set' do
          let(:options) { { 'some_other_key' => 'some_random_value' } }

          subject { described_class.call(data, options) }

          it 'creates a default develop environment for the given app' do
            expect(EnvironmentService).to receive(:create).with(app, options)

            subject
          end

          it 'creates a notification about the app creation' do
            expect(HookService).to receive(:call)
              .with(resource: app, action: 'create', value: 'success')

            subject
          end
        end
      end
    end
  end
end
