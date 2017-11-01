require 'rails_helper'

RSpec.describe Build, type: :model do
  subject do
    Build.create(
      environment: Environment.new(id: 'some_environment_id', app_id: 'some_app'),
      buildpack_id: 'ruby',
      repository: 'some repository',
      branch: 'master'
    )
  end

  it { is_expected.to be_valid }

  describe '#finish' do
    before do
      subject.state = previous_state
    end

    context 'when from a valid state' do
      before do
        subject.finish
      end

      context 'like pending' do
        let(:previous_state) { 'pending' }

        it 'transitions to ready' do
          expect(subject.state).to eq('ready')
        end

        it 'updates the built at attribute with the current time' do
          expect(subject.built_at).to eq(Time.zone.now)
        end
      end

      context 'like building' do
        let(:previous_state) { 'building' }

        it 'transitions to ready' do
          expect(subject.state).to eq('ready')
        end

        it 'updates the built at attribute with the current time' do
          expect(subject.built_at).to eq(Time.zone.now)
        end
      end
    end

    context 'when from an invalid state' do
      let(:previous_state) { 'broken' }

      it 'does not allow the transition to ready' do
        expect(subject.may_finish?).to eq(false)
      end
    end
  end

  describe '#path' do
    context 'when a base_path is given' do
      it "uses the provided value combined with the build's id" do
        expect(subject.path('some_base_path'))
          .to eq("some_base_path/#{subject.id}")
      end
    end

    context 'when a base_path is not given' do
      it "uses the default value from config combined with the build's id" do
        expect(subject.path)
          .to eq("#{Configurations.slug_builder.base_path}/#{subject.id}")
      end
    end
  end

  describe '#image_url' do
    context 'when a registry_url is given' do
      it "uses the provided value combined with the build's image_tag" do
        expect(subject.image_url('some_registry_url'))
          .to eq("some_registry_url/#{subject.image_tag}")
      end
    end

    context 'when a registry_url is not given' do
      it "uses the default value from config combined with the build's image_tag" do
        expect(subject.image_url)
          .to eq("#{Configurations.docker.private_registry_url}/#{subject.image_tag}")
      end
    end
  end

  describe '#image_tag' do
    it 'returns the environment.id:latest' do
      expect(subject.image_tag).to eq('some_environment_id:latest')
    end
  end

  describe '#buildpack' do
    before do
      allow(BuildpackService).to receive(:resolve)
        .with(subject.buildpack_id)
        .and_return(some_buildpack)
    end

    let(:some_buildpack) { double(:buildpack) }

    it 'resolves the value on BuildpackService' do
      expect(subject.buildpack).to eq(some_buildpack)
    end
  end

  describe '#log_content' do
    context 'when the build has a log' do
      let!(:log) do
        Log.create(
          content: 'This is the log of the commands executed to build the environment',
          build: subject
        )
      end

      it 'returns the content of the log' do
        expect(subject.log_content).to eq(log.content)
      end
    end

    context 'when the build does not have a log' do
      it 'returns an empty string' do
        expect(subject.log_content).to eq('')
      end
    end
  end

  describe '#app_id' do
    it 'returns the app_id of the build\'s environment' do
      expect(subject.app_id).to eq('some_app')
    end
  end
end
