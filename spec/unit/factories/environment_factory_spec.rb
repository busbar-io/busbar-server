require 'rails_helper'

RSpec.describe EnvironmentFactory do
  describe '.call' do
    subject { described_class.call(data: data, app: app) }

    let(:app) { App.create(id: 'app', buildpack_id: 'node', repository: 'some/repo') }

    after do
      app.destroy!
    end

    context 'when a data param is given' do
      let(:base_attributes) do
        {
          buildpack_id: 'custom_buildpack',
          default_branch: 'custom_branch',
          public: true
        }
      end

      context 'with a name key' do
        let(:data) do
          base_attributes.merge(name: 'some-custom-name')
        end

        it "creates an environment with data's data and the provided name" do
          expect(subject).to have_attributes(
            data.merge(name: 'some-custom-name')
          )
        end
      end

      context 'with no name key' do
        let(:data) { base_attributes }

        it "creates an environment with data's data and the default Configuration name" do
          expect(subject).to have_attributes(
            data.merge(name: Configurations.environments.default_name)
          )
        end
      end

      context 'with an id key' do
        let(:data) do
          base_attributes.merge(id: 'some_custom_id')
        end

        it "creates an environment with data's data and the provided id" do
          expect(subject).to have_attributes(
            data.merge(id: 'some_custom_id')
          )
        end
      end

      context 'with no id key' do
        let(:data) { base_attributes }

        before do
          allow(BSON::ObjectId).to receive(:new).and_return('89c8d25d912dae9dc21362e15e1281e0')
        end

        it "creates an environment with data's data and the default id" do
          expect(subject).to have_attributes(
            data.merge(id: '89c8d25d912dae9dc21362e15e1281e0')
          )
        end
      end

      context 'with a settings key' do
        let(:data) do
          base_attributes.merge(settings: { FOO: 'BAR' })
        end

        it "creates an environment with data's data and the provided id" do
          expect(subject).to have_attributes(
            data.merge(settings: { FOO: 'BAR' })
          )
        end
      end
    end

    context 'when a data param is not given' do
      let(:data) { {} }

      it "creates an environment with the given app's data and default values" do
        expect(subject).to have_attributes(
          app_id: app.id,
          buildpack_id: app.buildpack_id,
          default_branch: app.default_branch,
          public: false,
          settings: {}
        )
      end
    end
  end
end
