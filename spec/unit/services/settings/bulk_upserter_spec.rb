require 'spec_helper'

RSpec.describe Settings::BulkUpserter do
  describe '.call' do
    let(:environment) do
      Environment.new(
        _id: 'staging',
        app_id: 'some_app',
        buildpack_id: 'ruby'
      )
    end

    before do
      allow(HookService).to receive(:call).with(resource: environment, action: 'set', value: data)
    end

    after do
      environment.destroy!
    end

    let(:data) do
      {
        PUBLIC_URL: 'www.example.com',
        PRIVATE_URL: 'www.private-example.com',
        MONGO_URL: 'mongodb://example-mongo'
      }
    end

    it "updates the environment's settings" do
      described_class.call(environment, data)

      expect(environment.settings).to eq(
        'PUBLIC_URL' => 'www.example.com',
        'PRIVATE_URL' => 'www.private-example.com',
        'MONGO_URL' => 'mongodb://example-mongo'
      )
    end

    context 'when it fails to upsert the settings' do
      before do
        allow_any_instance_of(Setting).to receive(:valid?).and_return false

        allow(environment).to receive(:reload)
      end

      it 'does not reload the environment' do
        described_class.call(environment, data)

        expect(environment).to_not have_received(:reload)
      end

      it 'does not notifiy about the set' do
        expect(HookService).to_not receive(:call)

        described_class.call(environment, data)
      end
    end

    context 'when the deployment options are set to deploy the environment' do
      before do
        allow(DeploymentService).to receive(:create)
      end

      it 'redeploys the environment with the latest settings' do
        described_class.call(environment, data, deploy: true)

        expect(DeploymentService).to have_received(:create).with(environment, {}, build: false)
      end

      it 'notifies about the set' do
        expect(HookService).to receive(:call)
          .with(resource: environment, action: 'set', value: data)

        described_class.call(environment, data, deploy: true)
      end
    end

    context 'when the deployment options are set to not deploy the environment' do
      before do
        allow(DeploymentService).to receive(:create)
      end

      it 'does not deploy the environment' do
        described_class.call(environment, data, deploy: false)

        expect(DeploymentService).to_not have_received(:create).with(environment, {}, build: false)
      end

      it 'notifies about the set' do
        expect(HookService).to receive(:call)
          .with(resource: environment, action: 'set', value: data)

        described_class.call(environment, data, deploy: false)
      end
    end
  end
end
