require 'rails_helper'

RSpec.describe CustomBuildpack do
  it_behaves_like Buildpack

  let(:build) do
    instance_double(
      Build,
      environment: Environment.new,
      path: 'some_path',
      image_tag: 'some_image_tag',
      log: Log.new
    )
  end

  before do
    allow(File).to receive(:exists?)
      .with("#{build.path}/Dockerfile")
      .and_return(true)

    allow(build.log).to receive(:append_error)
  end

  describe '.call' do
    subject { described_class.call(build) }

    context 'when the custom dockerfile does not exist' do
      before do
        allow(File).to receive(:exists?)
          .with("#{build.path}/Dockerfile")
          .and_return(false)
      end

      it 'logs an error about the missing dockerfile' do
        begin
          subject
        rescue(Buildpack::CompileError)
          expect(build.log).to have_received(:append_error)
            .with('Missing dockerfile at the root of the application source code').once
        end
      end

      it 'raises an error about the missing dockerfile' do
        expect { subject }.to raise_error(Buildpack::CompileError)
      end
    end
  end
end
