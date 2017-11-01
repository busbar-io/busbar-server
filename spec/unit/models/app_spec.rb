require 'rails_helper'

RSpec.describe App, type: :model do
  subject do
    App.create(
      _id: SecureRandom.hex,
      buildpack_id: 'ruby',
      repository: 'git@example.com:EXAMPLE/app.git'
    )
  end

  after do
    subject.destroy
  end

  it { is_expected.to be_valid }

  it "isn't valid without an id" do
    subject.id = nil
    expect(subject).not_to be_valid
  end

  it "isn't valid without a buidpack_id" do
    subject.buildpack_id = nil
    expect(subject).not_to be_valid
  end

  it "isn't valid without a repository" do
    subject.repository = nil
    expect(subject).not_to be_valid
  end

  it "sets the default default_branch value to 'master'" do
    expect(subject.default_branch).to eq('master')
  end

  describe '#environment_names' do
    let!(:staging_environment) do
      Environment.create(
        _id: 'some_app-staging',
        app_id: subject.id,
        name: 'staging',
        buildpack_id: 'ruby',
        settings: {
          'MONGO_URL': 'mongodb://test',
          'REDIS_URL': 'redis://test'
        }
      )
    end

    let!(:production_environment) do
      Environment.create(
        _id: 'some_app-production',
        app_id: subject.id,
        name: 'production',
        buildpack_id: 'ruby',
        settings: {
          'MONGO_URL': 'mongodb://test',
          'REDIS_URL': 'redis://test'
        }
      )
    end

    after do
      staging_environment.destroy
      production_environment.destroy
    end

    it 'returns the environment names in a hash' do
      expect(subject.environment_names).to match(%w(staging production))
    end
  end
end
