require 'rails_helper'

RSpec.describe Deployment, type: :model do
  subject do
    Deployment.new(
      environment: Environment.new(
        name: 'staging',
        app_id: 'some_app_id',
        buildpack_id: 'ruby',
        id: SecureRandom.hex
      ),
      settings: { FOO: 'BAR', BAR: 'FOO' },
      build: Build.new(
        tag: '0.14.0',
        commit: 'bc21da2a5d0fd75c9981ced74b40c27f40420977',
        branch: 'develop'
      )
    )
  end

  let!(:some_log) { Log.new(build: subject.build) }

  it { is_expected.to be_valid }

  it "isn't valid without a environment_id" do
    subject.environment_id = nil
    expect(subject).not_to be_valid
  end

  it "sets the default state value to 'pending'" do
    expect(subject.state).to eq('pending')
  end

  describe '#tag' do
    context 'when the deployment has a build' do
      it 'returns the tag attribute from its build' do
        expect(subject.tag).to eq('0.14.0')
      end
    end

    context 'when the deployment does not have a build' do
      it "returns 'pending'" do
        subject.build = nil
        expect(subject.tag).to eq('pending')
      end
    end
  end

  describe '#start_building' do
    context 'when it can transit to building' do
      before do
        subject.state = 'pending'
        subject.build = nil
      end

      it 'transits to building' do
        subject.start_building

        expect(subject.state).to eq('building')
      end
    end

    context 'when it can not transit to building' do
      context 'when the current state does not transit to building' do
        before do
          subject.state = 'done'
        end

        it 'does not allow the transition to building' do
          expect(subject.may_start_building?).to eq(false)
        end
      end

      context 'when the current state transits to building but the deployment has a build' do
        before do
          subject.state = 'pending'
          subject.build = Build.new
        end

        it 'does not allow the transition to building' do
          expect(subject.may_start_building?).to eq(false)
        end
      end
    end
  end

  describe '#finish_building' do
    context 'when it can transit to building' do
      before do
        subject.state = 'building'
      end

      it 'transits to built' do
        subject.finish_building

        expect(subject.state).to eq('built')
      end
    end

    context 'when it can not transit to built' do
      before do
        subject.state = 'done'
      end

      it 'does not allow the transition to building' do
        expect(subject.may_finish_building?).to eq(false)
      end
    end
  end

  describe '#launch' do
    context 'when it can transit to launching' do
      before do
        subject.build_id = 'some_build_id'
      end

      context 'from pending' do
        before do
          subject.state = 'pending'
        end

        it 'transits to lauching' do
          subject.launch

          expect(subject.state).to eq('launching')
        end
      end

      context 'from built' do
        before do
          subject.state = 'built'
        end

        it 'transits to lauching' do
          subject.launch

          expect(subject.state).to eq('launching')
        end
      end
    end

    context 'when it can not transit to launching' do
      context 'when the current state does not transit to building' do
        before do
          subject.state = 'done'
        end

        it 'does not allow the transition to building' do
          expect(subject.may_launch?).to eq(false)
        end
      end

      context 'when the current state does not transit to launching' do
        before do
          subject.state = 'done'
        end

        it 'does not allow the transition to building' do
          expect(subject.may_launch?).to eq(false)
        end
      end
    end
  end

  describe '#commit' do
    context 'when the deployment has a build' do
      it 'returns the commit attribute from its build' do
        expect(subject.commit).to eq('bc21da2a5d0fd75c9981ced74b40c27f40420977')
      end
    end

    context 'when the deployment does not have a build' do
      it "returns 'pending'" do
        subject.build = nil
        expect(subject.commit).to eq('pending')
      end
    end
  end

  describe '#finish' do
    context 'when it can transit to done' do
      before do
        subject.state = 'launching'
      end

      it 'transits to done' do
        subject.finish

        expect(subject.state).to eq('done')
      end

      it 'updates the deployed_at attribute' do
        subject.finish

        expect(subject.deployed_at).to eq(Time.zone.now)
      end
    end

    context 'when it can not transit to done' do
      before do
        subject.state = 'done'
      end

      it 'does not allow the transition to done' do
        expect(subject.may_finish?).to eq(false)
      end
    end
  end

  describe '#fail' do
    context 'when it can transit to failed' do
      before do
        subject.state = 'launching'
      end

      it 'transits to failed' do
        subject.fail

        expect(subject.state).to eq('failed')
      end
    end

    context 'when it can not transit to failed' do
      before do
        subject.state = 'built'
      end

      it 'does not allow the transition to failed' do
        expect(subject.may_fail?).to eq(false)
      end
    end
  end

  describe '#log' do
    it 'returns the build log' do
      expect(subject.log).to eq(some_log)
    end
  end

  describe '#environment_name' do
    it 'returns the environment name' do
      expect(subject.environment_name).to eq('staging')
    end
  end

  describe '#app_id' do
    it 'returns the environment app_id' do
      expect(subject.app_id).to eq('some_app_id')
    end
  end
end
