module Ham
  class Gif < Model
    def self.search(query)
      return all if query.nil? or query.strip.empty?
      tags = Tag.search(query)
      gifs = tags.map(&:gifs).flatten
      return gifs
    end

    def self.tag(gif, tag)
      gif = gif.id if gif.respond_to?(:id)
      tag = tag.id if tag.respond_to?(:id)
      gif = Gif.retrieve(gif)
      tag = Tag.create(tag)
      redis.sadd("gif:#{gif.id}:tags", tag.id)
      redis.sadd("tag:#{tag.id}:gifs", gif.id)
      return tag
    end

    def self.untag(gif, tag)
      gif = gif.id if gif.respond_to?(:id)
      tag = tag.id if tag.respond_to?(:id)
      gif = Gif.retrieve(gif)
      tag = Tag.retrieve(tag)
      redis.srem("gif:#{gif.id}:tags", tag.id)
      redis.srem("tag:#{tag.id}:gifs", gif.id)
      return tag
    end

    def tags
      Tag.retrieve(redis.smembers("gif:#{id}:tags").sort)
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
end
