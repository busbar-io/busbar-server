require 'rails_helper'

RSpec.describe Environments::Cloner do
  describe '.call' do
    subject { described_class.call(environment, clone_name) }

    let(:clone_name) { 'my_clone' }
    let(:environment) do
      instance_double(
        Environment,
        app: some_app,
        name: 'staging',
        buildpack_id: 'ruby',
        default_branch: 'staging',
        public: true,
        default_node_id: '1x.standard',
        settings: {
          MONGO_URL: 'mongodb://some.mongo.url',
          REDIS_URL: 'redis://some.redis.url'
        }
      )
    end
    let(:some_app) { instance_double(App) }

    it 'creates an environment using the values of the original environment' do
      expect(EnvironmentService).to receive(:create).with(
        some_app,
        name: 'my_clone',
        buildpack_id: 'ruby',
        default_branch: 'staging',
        public: true,
        default_node_id: '1x.standard',
        settings: {
          MONGO_URL: 'mongodb://some.mongo.url',
          REDIS_URL: 'redis://some.redis.url'
        }
      )

      subject
    end

    context 'when the name of the clone is nil' do
      let(:clone_name) { nil }

      it 'creates an environment using the default name' do
        expect(EnvironmentService).to receive(:create).with(
          some_app,
          name: 'staging-clone',
          buildpack_id: 'ruby',
          default_branch: 'staging',
          public: true,
          default_node_id: '1x.standard',
          settings: {
            MONGO_URL: 'mongodb://some.mongo.url',
            REDIS_URL: 'redis://some.redis.url'
          }
        )

        subject
      end
    end
  end
end
