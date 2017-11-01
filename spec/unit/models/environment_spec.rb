require 'rails_helper'

RSpec.describe Environment, type: :model do
  subject do
    Environment.new(
      _id: SecureRandom.hex,
      app: some_app,
      buildpack_id: 'some_build_pack_id',
      name: 'develop'
    )
  end

  let(:some_app) do
    App.create(
      _id: 'some_app',
      buildpack_id: 'ruby',
      repository: 'git@example.com:EXAMPLE/app.git'
    )
  end

  after do
    some_app.destroy!
  end

  it { is_expected.to be_valid }

  it "isn't valid without an id" do
    subject.id = nil
    expect(subject).not_to be_valid
  end

  it "isn't valid with name that contains characters that are not letters, numbers, '.' or '-''" do
    subject.name = 'some_name'

    expect(subject).to_not be_valid
  end

  it "is valid with name that contains characters that are letters, numbers, '.' or '-''" do
    subject.name = 'abc.12-3'

    expect(subject).to be_valid
  end

  it "isn't valid without a buidpack_id" do
    subject.buildpack_id = nil
    expect(subject).not_to be_valid
  end

  it "isn't valid without a state" do
    subject.state = nil
    expect(subject).not_to be_valid
  end

  it "isn't valid with an name that already exists in its app" do
    some_app.environments << Environment.new(
      _id: SecureRandom.hex,
      app: some_app,
      buildpack_id: 'some_build_pack_id',
      name: 'develop'
    )

    expect(subject).to_not be_valid
  end

  it "sets the default default_branch value to 'master'" do
    expect(subject.default_branch).to eq('master')
  end

  it 'sets the default name to the default Configuration name' do
    expect(subject.name).to eq(Configurations.environments.default_name)
  end

  it 'sets the default public value to false' do
    expect(subject.public).to eq(false)
  end

  it "sets the default state value to 'new'" do
    expect(subject.state).to eq('new')
  end

  it 'sets the default settings value to an empty hash' do
    expect(subject.settings).to eq({})
  end

  describe '#namespace' do
    it "returns environment's name" do
      expect(subject.namespace).to eq('develop')
    end
  end

  describe '#latest_build' do
    let!(:first_build) do
      Build.create(
        environment_id: subject.id,
        buildpack_id: 'java',
        repository: 'some_repo',
        branch: 'staging',
        created_at: Time.zone.now - 1.hour
      )
    end

    let!(:latest_build) do
      Build.create(
        environment_id: subject.id,
        buildpack_id: 'ruby',
        repository: 'some_repo',
        branch: 'master',
        created_at: Time.zone.now
      )
    end

    after do
      latest_build.destroy!
      first_build.destroy!
    end

    it 'returns latest build of the environment' do
      expect(subject.latest_build).to eq(latest_build)
    end
  end

  describe '#latest_built_build' do
    let!(:first_build) do
      Build.create(
        environment_id: subject.id,
        state: 'ready',
        buildpack_id: 'java',
        repository: 'some_repo',
        branch: 'staging',
        built_at: Time.zone.now - 1.hour
      )
    end

    let!(:build_not_built) do
      Build.create(
        environment_id: subject.id,
        state: 'pending',
        buildpack_id: 'java',
        repository: 'some_repo',
        branch: 'staging',
        built_at: Time.zone.now + 1.hour
      )
    end

    let!(:latest_build) do
      Build.create(
        environment_id: subject.id,
        state: 'ready',
        buildpack_id: 'ruby',
        repository: 'some_repo',
        branch: 'master',
        built_at: Time.zone.now
      )
    end

    after do
      first_build.destroy!
      build_not_built.destroy!
      latest_build.destroy!
    end

    it 'returns latest build ready of the environment' do
      expect(subject.latest_built_build).to eq(latest_build)
    end
  end

  describe '#latest_deployment' do
    let!(:first_deployment) do
      Deployment.create(
        environment_id: subject.id,
        state: 'done',
        deployed_at: Time.zone.now - 1.hour
      )
    end

    let!(:deployment_not_done) do
      Deployment.create(
        environment_id: subject.id,
        state: 'pending',
        deployed_at: Time.zone.now + 1.hour
      )
    end

    let!(:latest_deployment) do
      Deployment.create(
        environment_id: subject.id,
        state: 'done',
        deployed_at: Time.zone.now
      )
    end

    after do
      first_deployment.destroy!
      deployment_not_done.destroy!
      latest_deployment.destroy!
    end

    it 'returns latest deployment done of the environment' do
      expect(subject.latest_deployment).to eq(latest_deployment)
    end
  end

  describe '#log' do
    let(:build) do
      Build.create(
        environment_id: subject.id,
        state: 'ready',
        buildpack_id: 'ruby',
        repository: 'some_repo',
        branch: 'master',
        built_at: Time.zone.now
      )
    end

    let!(:some_log) { Log.create(build: build) }

    after do
      build.destroy!
      some_log.destroy!
    end

    it 'returns the lastest build log' do
      expect(subject.log).to eq(some_log)
    end
  end
end
