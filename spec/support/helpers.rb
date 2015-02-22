module Gifs
  module TestHelpers

    def clear_redis!
      keys = $redis.keys '*'
      $redis.del(*keys) if keys.any?
    end

  end
end

