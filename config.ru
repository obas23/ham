$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'

Bundler.require

Redis.current = Redis.new url: ENV.fetch('REDIS_URL')
$redis ||= Redis.current

require 'lib/ham'

map "/" do
  run Ham::App
end

map "/api" do
  run Ham::API
end

