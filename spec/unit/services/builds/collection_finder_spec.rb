require 'rails_helper'

RSpec.describe Builds::CollectionFinder do
  let(:environment) { Environment.new }
  let(:builds) { [Build.new] }

  subject { described_class.call(environment) }

  before do
    allow(environment).to receive_message_chain(:builds, :desc, :limit).and_return(builds)
  end

  describe '.call' do
    it 'finds the last builds for a given environment' do
      is_expected.to eq(builds)
    end
  end
end
