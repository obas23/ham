class Gif < Model
  def self.search(query)
    return all if query.nil? or query.strip.empty?
    tags = Tag.search(query)
    gifs = tags.map(&:gifs).flatten
    return gifs
  end

  def tags
    $redis.smembers("gif:#{id}:tags").map { |tag| Tag.retrieve(tag) }
  end

  def tag!(tag)
    tag = Tag.create(tag)
    $redis.sadd("gif:#{id}:tags", tag.id)
    $redis.sadd("tag:#{tag.id}:gifs", id)
  end

  def untag!(tag)
    tag = Tag.retrieve(tag)
    $redis.srem("gif:#{id}:tags", tag.id)
    $redis.srem("tag:#{tag.id}:gifs", id)
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

  def next
    Gif.next(id)
  end

  def prev
    Gif.prev(id)
  end

  def synced?
    @synced ||= begin
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Head.new(uri.request_uri)
      response = http.request(request)
      response.instance_of? Net::HTTPOK
    end
  end
end

