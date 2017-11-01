require 'rails_helper'

RSpec.describe LockService do
  let(:data)    { { app_id: 'test' } }
  let(:ttl)     { 60 }
  let(:prefix)  { 'test' }
  let(:key)     { [prefix, Digest::SHA2.hexdigest(data.sort.flatten.join('::'))].join('::') }
  let(:adapter) { instance_double(Redis) }

  before do
    LockService.adapter = adapter
    LockService.prefix  = prefix
  end

  describe '.acquire' do
    subject { described_class.acquire(data, ttl) }

    before do
      allow(adapter).to receive(:set).with(key, 1, nx: 1, ex: ttl).and_return(true)
    end

    it 'acquires the lock for a given key' do
      expect(adapter).to receive(:set).with(key, 1, nx: 1, ex: ttl)
      subject
    end
  end

  describe '.release' do
    subject { described_class.release(data) }

    before do
      allow(adapter).to receive(:del).with(key).and_return('1')
    end

    it 'releases the lock for a given key' do
      expect(adapter).to receive(:del).with(key)
      subject
    end
  end

  describe '.synchronize' do
    before do
      allow(adapter).to receive(:del).with(key).and_return('1')
    end

    context 'when the lock can be acquired' do
      before do
        allow_any_instance_of(described_class).to receive(:acquire).with(data, ttl).and_return(true)
        allow_any_instance_of(described_class).to receive(:release).with(data).and_return(true)
      end

      it 'executes a block synchronously on the lock for a given key' do
        expect_any_instance_of(described_class).to receive(:acquire).with(data, ttl).once
        expect_any_instance_of(described_class).to receive(:release).with(data).once
        expect { |b| described_class.synchronize(data, ttl, &b) }.to yield_control.once
      end
    end

    context 'when the lock cannot be acquired' do
      before do
        allow_any_instance_of(described_class).to receive(:acquire)
          .with(data, ttl)
          .and_return(false, true)

        allow_any_instance_of(described_class).to receive(:release).with(data).and_return(true)
        allow_any_instance_of(described_class).to receive(:sleep).with(1)
      end

      it 'waits until the lock is free' do
        expect_any_instance_of(described_class).to receive(:acquire).and_return(false)
        expect_any_instance_of(described_class).to receive(:acquire).and_return(true)
        expect_any_instance_of(described_class).to receive(:sleep).with(1)
        expect { |b| described_class.synchronize(data, ttl, &b) }.to yield_control
      end

      context 'when the wait time is greater than the ttl' do
        let(:error) { LockService::LockTimeoutError }
        let(:ttl) { 0 }

        before do
          allow_any_instance_of(described_class).to receive(:acquire)
            .with(data, ttl)
            .and_return(false)

          allow_any_instance_of(described_class).to receive(:sleep).with(1)

          Timecop.return
        end

        it 'raises a LockTimeoutError' do
          expect_any_instance_of(described_class).to receive(:acquire).and_return(false)
          expect_any_instance_of(described_class).to receive(:sleep).with(1)
          expect { |b| described_class.synchronize(data, ttl, &b) }.to raise_error(error)
        end
      end
    end
  end
end
