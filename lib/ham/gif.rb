module Ham
  class Gif
    NotFound = Class.new(Ham::NotFound)

    def self.db
      Ham.db
    end

    def self.create(id)
      db.insert(:gifs, id)
      new(id)
    end

    def self.ids
      db.ids(:gifs)
    end

    def self.all
      ids.map { |id| new(id) }
    end

    def self.find(id)
      record = db.find(:gifs, id)
      raise NotFound, "id=#{id}" if record.nil?
      return new(record)
    end

    def self.first
      id = db.first(:gifs)
      return nil if id.nil?
      return new(id)
    end

    def self.last
      id = db.last(:gifs)
      return nil if id.nil?
      return new(id)
    end

    def self.next(id)
      id = db.next(:gifs, id) || db.first(:gifs)
      return nil if id.nil?
      return new(id)
    end

    def self.prev(id)
      id = db.prev(:gifs, id) || db.last(:gifs)
      return nil if id.nil?
      return new(id)
    end

    def self.search(query)
      return all if query.nil? or query.strip.empty?
      tags = Tag.search(query)
      gifs = tags.map(&:gifs).flatten
      return gifs
    end

    def self.tags(gif_id)
      tag_ids = db.execute("select tag_id from gifs_tags where gif_id='#{gif_id}'").values.flatten
      tag_ids.map { |tag_id| Tag.find(tag_id) }
    end

    def self.tag(gif_id, tag_id)
      gif = Gif.find(gif_id)
      tag = Tag.create(tag_id)
      return tag if gif.tags.include?(tag)
      db.execute("insert into gifs_tags (gif_id, tag_id) values ('#{gif.id}','#{tag.id}')")
      return tag
    end

    def self.untag(gif_id, tag_id)
      gif = Gif.find(gif_id)
      tag = Tag.find(tag_id)
      db.execute("delete from gifs_tags where gif_id='#{gif.id}' and tag_id='#{tag.id}'")
      return tag
    end

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def ==(other)
      self.id == other.id
    end

    def url
      "http://i.imgur.com/#{id}.gif"
    end

    def thumbnail_url
      "http://i.imgur.com/#{id}b.gif"
    end

    def next
      @next ||= Gif.next(id)
    end

    def prev
      @prev ||= Gif.prev(id)
    end

    def tags
      @tags ||= Gif.tags(id)
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

    def to_json(*a)
      as_json.to_json(*a)
    end

    def as_json(*a)
      attributes
    end
  end
end

