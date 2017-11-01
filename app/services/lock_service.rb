class LockService
  include Singleton

  TTL = Configurations.locks.default_ttl

  attr_accessor :prefix, :adapter

  LockTimeoutError = Class.new(StandardError)

  class << self
    extend Forwardable

    def_delegators :instance,
                   :prefix,
                   :prefix=,
                   :adapter,
                   :adapter=,
                   :acquire,
                   :release,
                   :synchronize
  end

  def acquire(data, ttl = TTL)
    key = key_for(data)
    adapter.set(key, 1, nx: 1, ex: ttl)
  end

  def release(data)
    key = key_for(data)
    adapter.del(key).to_i != 0
  end

  def synchronize(data, timeout = 1.minutes.to_i)
    start_time = Time.zone.now

    loop do
      if acquire(data, timeout)
        yield
        break
      else
        time = Time.zone.now
        raise(LockTimeoutError, data) if (time - start_time).to_i > timeout
        sleep(1)
      end
    end
  ensure
    release(data)
  end

  private

  def key_for(data)
    [prefix, Digest::SHA2.hexdigest(data.sort.flatten.join('::'))].join('::')
  end
end
