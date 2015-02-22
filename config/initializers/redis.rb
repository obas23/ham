Redis.current = Redis.new url: ENV.fetch('REDIS_URL'), db: ENV.fetch('REDIS_DB')
$redis = Redis.current

