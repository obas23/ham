$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'

Bundler.require

require 'lib/ham'

map "/" do
  run Ham::Web::App
end

map "/api" do
  run Ham::Web::API
end

