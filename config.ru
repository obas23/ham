$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'

Bundler.require

require 'lib/ham'

Redis.current = Redis.new(url: ENV.fetch('REDIS_URL'))
Ham.redis = Redis.current

map "/" do
  run Ham::Web::App
end

map "/api" do
  run Ham::Web::API
end

