require 'rails_helper'

RSpec.describe Settings::Destroyer do
  describe '.call' do
    subject { described_class.call(environment, removed_setting) }

    let(:environment) do
      instance_double(
        Environment,
        settings: {
          'PORT' => '8080',
          'MONGO_URL' => 'mongodb://some.url',
          'REDIS_URL' => 'redis://some.url'
        }
      )
    end

    let(:removed_setting) do
      Setting.new(key: 'PORT', value: '8080')
    end

    before do
      allow(DeploymentService).to receive(:create).with(environment, {}, build: false)

      allow(HookService).to receive(:call)
        .with(
          resource: environment,
          action: 'unset',
          value: { removed_setting.key => removed_setting.value }
        )

      allow(environment).to receive(:update_attributes).and_return(true)
    end

    context 'when the setting exists' do
      it 'removes the setting from the environment' do
        expect(environment).to receive(:update_attributes)
          .with(settings:
                  { 'MONGO_URL' => 'mongodb://some.url',  'REDIS_URL' => 'redis://some.url' }
               ).once

        subject
      end

      it 'notifies about the unsetting' do
        expect(HookService).to receive(:call)
          .with(
            resource: environment,
            action: 'unset',
            value: { removed_setting.key => removed_setting.value }
          )

        subject
      end

      it 'deploys the environment' do
        expect(DeploymentService).to receive(:create).with(environment, {}, build: false).once

        subject
      end
    end

    context 'when the setting does not exist' do
      let(:removed_setting) do
        Setting.new(key: 'SOME_NON_EXISTING_SETTING', value: '8080')
      end

      it 'does not change the current settigns of the environment' do
        expect(environment).to_not receive(:update_attributes)

        subject
      end

      it 'does not notify about the unsetting' do
        expect(HookService).to_not receive(:call)

        subject
      end

      it 'does not deploy the environment' do
        expect(DeploymentService).to_not receive(:create)

        subject
      end
    end
  end
end
