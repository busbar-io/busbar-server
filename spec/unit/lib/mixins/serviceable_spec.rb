require 'rails_helper'

RSpec.describe Serviceable do
  describe '.call' do
    let(:serviceable) { Class.new { include Serviceable } }

    subject { serviceable.call('anything') }

    it 'raises a NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end
end
