require 'rails_helper'

RSpec.describe CommandExecutorAndLogger do
  describe '.call' do
    subject { described_class.call(command, loggable) }

    let(:loggable) { double(:loggable, content: 'some content') }
    let(:command) { 'some command' }
    let(:command_output) { 'some command executed' }
    let(:exit_status) { true }

    before do
      allow(loggable).to receive(:append)

      allow(Open3).to receive(:capture2e)
        .with(command)
        .and_return(
          [
            command_output,
            double(:status, success?: exit_status)
          ]
        )
    end

    context 'when the command exit status is 0' do
      let(:exit_status) { true }

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'when the command exit status is not 0' do
      let(:exit_status) { false }

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end

    it 'updates the log of the given loggable' do
      expect(loggable).to receive(:append).with(command_output).once

      subject
    end

    it 'executes the command redirecting the output' do
      expect(Open3).to receive(:capture2e).with(command).once

      subject
    end
  end
end
