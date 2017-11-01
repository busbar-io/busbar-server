LockService.adapter = Redis.new(url: Configurations.redis.url)
LockService.prefix = Configurations.locks.prefix
