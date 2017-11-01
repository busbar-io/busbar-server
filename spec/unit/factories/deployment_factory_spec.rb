require 'rails_helper'

RSpec.describe DeploymentFactory do
  describe '.call' do
    let(:settings)    { Hash.new }
    let(:build)       { Build.new }
    let(:environment) { Environment.new(settings: settings) }
    let(:data)        { Hash.new }
    let(:options)     { Hash.new }

    subject { described_class.call(environment, data, options) }

    before do
      allow(environment).to receive(:latest_built_build).and_return(build)
    end

    context 'when the option to build is set to true' do
      let(:options)  { { build: true } }

      context 'when there is not a previous build id' do
        before do
          allow(environment).to receive(:latest_built_build).and_return(nil)
        end

        it 'creates a Deployment with an undefined Build ID' do
          expect(subject.build_id).to be_nil
        end
      end

      context "when there's a previous build id" do
        it 'creates a Deployment with an undefined Build ID' do
          expect(subject.build_id).to be_nil
        end
      end
    end

    context 'when the build option is set to false' do
      let(:options)  { { build: false } }

      context 'when the data has a build_id' do
        let(:build_id) { 'build_id_defined_in_options' }
        let(:data)     { { build_id: 'test' } }

        it 'creates a Deployment with the given Build ID' do
          expect(subject.build_id).to eq data[:build_id]
        end
      end

      context 'when the data does not have a build_id' do
        context 'when the environment has a previous build' do
          it 'creates a Deployment using the latest Build ID from the App' do
            expect(subject.build_id).to eq build.id
          end

          it 'creates a Deployment with a built state' do
            expect(subject.state).to eq 'built'
          end
        end

        context 'when the environment does not have a previous build' do
          before do
            allow(environment).to receive(:latest_built_build).and_return(nil)
          end

          it 'creates a Deployment without a build_id' do
            expect(subject.build_id).to be_nil
          end
        end
      end
    end
  end
end
