require 'rails_helper'

RSpec.describe Builds::Creator do
  describe '.call' do
    let(:environment) { Environment.new }
    let(:build) do
      instance_double(
        Build,
        valid?: build_valid,
        save: build_saved,
        log: instance_double(Log, save: log_saved)
      )
    end
    let(:data)        { Hash.new }
    let(:options)     { Hash.new }
    let(:build_saved) { true }
    let(:build_valid) { true }
    let(:log_saved)   { true }

    subject { described_class.call(environment, data, options) }

    before do
      allow(BuildFactory).to receive(:call).with(environment, data).and_return(build)
      allow(BuildService).to receive(:compile).with(build, options)
    end

    it 'creates a build' do
      expect(BuildFactory).to receive(:call).with(environment, data)
      subject
    end

    context 'when options[:compile] is set to false' do
      let(:options) { { compile: false } }

      it 'does not compile the build' do
        expect(BuildService).not_to receive(:compile)
        subject
      end
    end

    context 'when options[:compile] is set to true or not defined' do
      it 'compiles the created build' do
        expect(BuildService).to receive(:compile).with(build, options)
        subject
      end
    end

    context 'when the created buid is invalid' do
      let(:build_valid) { false }

      it 'does not compile the build' do
        expect(BuildService).to_not receive(:compile)
        subject
      end
    end

    context 'when it can not save the created build' do
      let(:build_saved) { false }

      it 'does not compile the build' do
        expect(BuildService).to_not receive(:compile)
        subject
      end
    end

    context 'when it can not save the created build log' do
      let(:log_saved) { false }

      it 'does not compile the build' do
        expect(BuildService).to_not receive(:compile)
        subject
      end
    end
  end
end
