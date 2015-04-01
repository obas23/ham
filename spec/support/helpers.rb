module Ham
  module TestHelpers

    def clear_redis!
      keys = Ham.redis.keys '*'
      Ham.redis.del(*keys) if keys.any?
    end

  end
end

