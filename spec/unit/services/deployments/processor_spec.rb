require 'rails_helper'

RSpec.describe Deployments::Processor do
  describe '.call' do
    let(:deployment) { Deployment.new }
    let(:options) { { resize_components: true } }

    subject { described_class.call(deployment, options) }

    before do
      allow(Deployments::Processor::BuildInjector).to receive(:call).with(deployment)
      allow(Deployments::Processor::Launcher).to receive(:call).with(deployment, options)
      allow(deployment).to receive(:may_start_building?).and_return(true)
      allow(deployment).to receive(:start_building!).and_return(true)
      allow(deployment).to receive(:finish_building!).and_return(true)
      allow(deployment).to receive(:environment_name).and_return('staging')
      allow(deployment).to receive(:launch!).and_return(true)
      allow(deployment).to receive(:finish!).and_return(true)
      allow(HookService).to receive(:call)
        .with(resource: deployment, action: 'finish', value: 'success')
    end

    context 'when the deployment may start building' do
      it 'returns the deployment' do
        expect(subject).to eq(deployment)
      end

      it 'injects the build' do
        expect(Deployments::Processor::BuildInjector).to receive(:call).with(deployment)
        subject
      end

      it 'does not notify about the deploy' do
        expect(HookService).to_not receive(:call)

        subject
      end

      context 'when there is a option to notify about the deploy' do
        let(:options) { { resize_components: true, notifiy: true } }

        it 'creates a notification about the environment deploy' do
          expect(HookService).to receive(:call)
            .with(resource: deployment, action: 'finish', value: 'success')

          subject
        end

        context 'when the build injection fails' do
          before do
            allow(Deployments::Processor::BuildInjector).to receive(:call)
              .with(deployment)
              .and_raise(Deployments::Processor::BuildInjector::BuildInjectionError)
          end

          it 'notifies the failure' do
            expect(HookService).to receive(:call)
              .with(resource: deployment, action: 'build', value: 'fail')

            subject
          end
        end
      end

      context 'when the build injection fails' do
        before do
          allow(Deployments::Processor::BuildInjector).to receive(:call)
            .with(deployment)
            .and_raise(Deployments::Processor::BuildInjector::BuildInjectionError)
        end

        it 'makes the deploy fail' do
          expect(deployment).to receive(:fail!)

          subject
        end

        it 'returns the deployment' do
          expect(subject).to eq(deployment)
        end

        it 'does not launch the deployment' do
          expect(Deployments::Processor::Launcher).to_not receive(:call)

          subject
        end

        it 'does not call the deployment launcher' do
          expect(Deployments::Processor::Launcher).to_not receive(:call)

          subject
        end

        it 'does not launch the deployment' do
          expect(deployment).to_not receive(:launch!)

          subject
        end

        it 'does not finish the deployment' do
          expect(deployment).to_not receive(:finish!)

          subject
        end

        it 'does not notify about the deployment creation' do
          expect(HookService).to_not receive(:call)
            .with(resource: deployment, action: 'finish', value: 'success')

          subject
        end
      end
    end

    context 'when the deployment may not start building' do
      before do
        allow(deployment).to receive(:may_start_building?).and_return false
      end

      it 'does not attempt to build' do
        expect(Deployments::Processor::BuildInjector).not_to receive(:call)
        subject
      end

      it 'does not notify about the deploy' do
        expect(HookService).to_not receive(:call)

        subject
      end

      context 'when there is a option to notify about the deploy' do
        let(:options) { { resize_components: true, notifiy: true } }

        it 'creates a notification about the environment deploy' do
          expect(HookService).to receive(:call)
            .with(resource: deployment, action: 'finish', value: 'success')

          subject
        end
      end
    end

    it 'launches the deployment' do
      expect(Deployments::Processor::Launcher).to receive(:call).with(deployment, options).once
      subject
    end
  end
end
