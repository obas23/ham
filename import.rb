$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler'

Bundler.require

require 'lib/ham'

Ham.db.reset!

Gif = Struct.new(:name, :mtime)

Dir["/Users/caseyohara/Dropbox/Pictures/gifs/*.gif"].map do |file|
  Gif.new file.split("/").last.split(".").first, File.mtime(file)
end.sort_by(&:mtime).each do |gif|
  Ham::Gif.create(gif.name)
end

exit

