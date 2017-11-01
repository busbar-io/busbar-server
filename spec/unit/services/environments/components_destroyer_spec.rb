require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Environments::ComponentsDestroyer do
  describe '.call' do
    subject { described_class.call(environment) }

    let(:environment) do
      Environment.new(id: 'staging')
    end

    let!(:components) do
      %w(web worker clock).each do |type|
        Component.new(
          environment: environment,
          command: 'a command',
          type: type,
          scale: 1,
          image_url: 'a image'
        )
      end
    end

    before do
      allow(ComponentService).to receive(:destroy)
    end

    it 'destroys all of its components' do
      subject

      environment.components.each do |component|
        expect(ComponentService).to have_received(:destroy).with(component).once
      end
    end
  end
end
