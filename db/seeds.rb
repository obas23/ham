Gif.delete_all

files = Dir["/Users/caseyohara/Dropbox/Pictures/gifs/**/*.gif"]

files.each do |file|
  id = file.split('/').last.split('.').first
  mtime = File.mtime(file)

  gif = Gif.new id: id
  gif.created_at = mtime
  gif.updated_at = mtime
  gif.save!
end

