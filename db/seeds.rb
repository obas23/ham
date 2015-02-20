files = Dir["/Users/caseyohara/Dropbox/Pictures/gifs/*.gif"]

files.each do |file|
  id    = file.split('/').last.split('.').first
  mtime = File.mtime(file)

  Gif.find_or_create_by id: id do |gif|
    gif.created_at = mtime
    gif.updated_at = mtime
  end
end

