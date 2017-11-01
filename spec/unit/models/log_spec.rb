require 'rails_helper'

RSpec.describe Log, type: :model do
  subject do
    Log.new(
      content: 'This is the content of the log'
    )
  end

  it { is_expected.to be_valid }

  describe '#append' do
    it 'increments the current content of the log with the new lines after a \n' do
      subject.append('This is a new line on the log')

      expect(subject.content).to eq("This is the content of the log\nThis is a new line on the log")
    end
  end

  describe '#append_step' do
    it 'appends a step message with the proper formating' do
      subject.append_step('This line describes a command executed')

      expect(subject.content).to eq(
        "This is the content of the log\n" \
        "==========================================\n" \
        "= This line describes a command executed =\n" \
        "==========================================\n"
      )
    end
  end

  describe '#append_error' do
    it 'appends a error message with the proper formating' do
      subject.append_error('This is an error message')

      expect(subject.content).to eq(
        "This is the content of the log\n" \
        "!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n" \
        "! This is an error message !\n" \
        "!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
      )
    end
  end
end
