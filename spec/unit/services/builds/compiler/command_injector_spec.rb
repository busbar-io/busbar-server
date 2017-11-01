require 'rails_helper'

RSpec.describe Builds::Compiler::CommandInjector do
  describe '.call' do
    let(:build)    { Build.new }
    let(:commands) { { 'web' => 'bundle exec puma' } }
    let(:procfile) { commands.map { |k, v| "#{k}: #{v}" }.join("\n") }

    subject { described_class.call(build) }

    before do
      allow(File).to receive(:read).with("#{build.path}/Procfile").and_return(procfile)
      allow(build).to receive(:update_attributes).and_return(true)
    end

    it 'injects the commands into the build' do
      expect(build).to receive(:update_attributes).with(commands: commands)
      subject
    end
  end
end
