require 'rails_helper'

RSpec.describe Settings::Destroyer do
  describe '.call' do
    subject { described_class.call(environment, removed_setting) }

    let!(:some_app) do
      App.create(
        _id: 'some_app',
        buildpack_id: 'ruby',
        repository: 'git@example.com:EXAMPLE/app.git'
      )
    end

    let!(:environment) do
      Environment.create(
        _id: 'staging',
        app_id: some_app.id,
        name: 'staging',
        buildpack_id: 'ruby',
        settings: {
          'MONGO_URL' => 'mongodb://some.url',
          'REDIS_URL' => 'redis://some.url'
        }
      )
    end

    let(:removed_setting) do
      Setting.new(key: 'PORT', value: '8080')
    end

    after do
      some_app.destroy!
      environment.destroy!
    end
    context 'when the setting exists' do
      it 'removes the setting from the environment' do
        subject

        expect(environment.settings)
          .to eq('MONGO_URL' => 'mongodb://some.url',  'REDIS_URL' => 'redis://some.url')
      end
    end

    context 'when the setting does not exist' do
      let(:removed_setting) do
        Setting.new(key: 'SOME_NON_EXISTING_SETTING', value: '8080')
      end

      it 'does not change the current settigns of the environment' do
        expect { subject }.to_not change(environment, :settings)
      end
    end
  end
end
