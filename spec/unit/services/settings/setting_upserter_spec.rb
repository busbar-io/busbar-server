require 'spec_helper'

RSpec.describe Settings::SettingUpserter do
  let(:environment) do
    Environment.new(
      _id: 'staging',
      app_id: 'some_app',
      buildpack_id: 'ruby'
    )
  end

  after do
    environment.destroy!
  end

  let(:update_query) do
    { 'settings.some_setting' => 'new_value' }
  end

  describe '.call' do
    context 'when the operation suceeds' do
      it 'reloads the environment' do
        allow(environment).to receive(:reload)

        described_class.call(environment, update_query)

        expect(environment).to have_received(:reload).once
      end

      it 'updates the environment settings' do
        described_class.call(environment, update_query)

        expect(environment.settings).to eq('some_setting' => 'new_value')
      end
    end

    context 'when the operation fails' do
      before do
        allow(Environment).to receive_message_chain(:where, :find_one_and_update)
          .and_return(nil)
      end

      it 'does not reload the environment' do
        allow(environment).to receive(:reload)
        described_class.call(environment, update_query)

        expect(environment).to_not have_received(:reload)
      end
    end

    context 'when the given query is empty' do
      it 'does no raise an error' do
        expect { described_class.call(environment, {}) }.to_not raise_error
      end
    end
  end
end
