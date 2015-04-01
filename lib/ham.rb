require 'json'

require_relative "ham/errors"
require_relative "ham/model"
require_relative "ham/gif"
require_relative "ham/tag"
require_relative "ham/web/app"
require_relative "ham/web/api"

module Ham
  def self.redis
    @redis ||= Redis.current
  end

  def self.redis=(redis)
    @redis = redis
  end
end

