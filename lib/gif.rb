class Gif < Model
  def self.search(query)
    return all if query.nil? or query.strip.empty?
    tags = Tag.search(query)
    gifs = tags.map(&:gifs).flatten
    return gifs
  end

  def tags
    $redis.smembers("gif:#{id}:tags").sort.map { |tag| Tag.retrieve(tag) }
  end

  def tag!(tag)
    tag = Tag.create(tag)
    $redis.sadd("gif:#{id}:tags", tag.id)
    $redis.sadd("tag:#{tag.id}:gifs", id)
    return tag
  end

  def untag!(tag)
    tag = Tag.retrieve(tag)
    $redis.srem("gif:#{id}:tags", tag.id)
    $redis.srem("tag:#{tag.id}:gifs", id)
    return tag
  end

  def url
    "http://i.imgur.com/#{id}.gif"
  end

  def thumbnail_url
    "http://i.imgur.com/#{id}b.gif"
  end

  def to_param
    id
  end

  def attributes
    {
      id: id,
      url: url,
      thumbnail_url: thumbnail_url
    }
  end
end

