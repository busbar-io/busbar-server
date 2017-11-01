require 'rails_helper'

RSpec.describe Settings::Upserter do
  describe '.call' do
    let(:environment)       { Environment.new }
    let(:data)              { { key: 'test_key', value: 'test_value' } }
    let(:update)            { { '$set' => { "settings.#{data[:key]}" => data[:value] } } }
    let(:deployment_params) { { deploy: true } }
    let(:operation)         { instance_double(Mongo::Operation::Result) }

    subject { described_class.call(environment, data, deployment_params) }

    before do
      allow(Environment).to receive_message_chain(:where, :find_one_and_update)
        .with(update, upsert: true, return_document: :after)
        .and_return(operation)

      allow(DeploymentService).to receive(:create).with(environment, {}, build: false)
      allow(environment).to receive(:reload).and_return(environment)
    end

    it 'updates the environment settings' do
      expect(Environment).to receive_message_chain(:where, :find_one_and_update)
        .with(update, upsert: true, return_document: :after)
      expect(environment).to receive(:reload)
      subject
    end

    context 'when it fails to upsert the settings' do
      let(:setting) { Setting.new(data) }
      let(:errors)  { ActiveModel::Errors.new(setting) }

      before do
        allow(Environment).to receive_message_chain(:where, :find_one_and_update)
          .with(update, upsert: true, return_document: :after)
          .and_return(nil)

        allow(Setting).to receive(:new).and_return(setting)
        allow(setting).to receive(:errors).and_return(errors)
        allow(errors).to receive(:add)
      end

      it 'does not reload the environment' do
        expect(environment).not_to receive(:reload)
        subject
      end

      it 'adds an error to the setting' do
        expect_any_instance_of(Setting).to receive_message_chain(:errors, :add)
        subject
      end
    end

    context 'when the deployment options are set to deploy the environment' do
      it 'redeploys the environment with the latest settings' do
        expect(DeploymentService).to receive(:create).with(environment, {}, build: false)
        subject
      end
    end

    context 'when the deployment options are set to not deploy the environment' do
      let(:deployment_params) { { deploy: false } }

      it 'does not deploy the environment' do
        expect(DeploymentService).not_to receive(:create)
        subject
      end
    end
  end
end
