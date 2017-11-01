require 'rails_helper'

RSpec.describe CommandExecutorAndLogger do
  describe '.call' do
    subject { described_class.call('echo test', loggable) }

    let(:loggable) { Log.new(content: 'some content') }

    it 'returns true if the status of the command execution is 0' do
      expect(subject).to eq(true)
    end

    it 'updates the log of the given loggable' do
      subject

      expect(loggable.content).to eq("some content\ntest\n")
    end

    context 'when the command exit status is not 0' do
      subject { described_class.call('exit 1', loggable) }

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end
end
