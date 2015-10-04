module Ham
  class Tag
    NotFound = Class.new(Ham::NotFound)

    def self.db
      Ham.db
    end

    def self.create(id)
      id = normalize(id)
      db.insert(:tags, id)
      new(id)
    end

    def self.ids
      db.ids(:tags)
    end

    def self.all
      ids.map { |id| new(id) }
    end

    def self.find(id)
      id = normalize(id)
      record = db.find(:tags, id)
      raise NotFound, "id=#{id}" if record.nil?
      return new(record)
    end

    def self.normalize(id)
      id.to_s.strip.downcase.gsub(/[^a-z\d\s-]+/,'').gsub(/\s+/, '-')
    end

    def self.search(query)
      query = normalize(query)
      results = db.search(:tags, query)
      results.map { |id| new(id) }
    end

    def self.complete(query)
      query = normalize(query)
      results = db.complete(:tags, query)
      results.map { |id| new(id) }
    end

    def self.gifs(tag_id)
      gif_ids = db.execute('select gif_id from gifs_tags where tag_id=?', tag_id).flatten
      gif_ids.map { |gif_id| Gif.find(gif_id) }
    end

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def ==(other)
      self.id == other.id
    end

    def gifs
      @gifs ||= Tag.gifs(id)
    end

    def text
      id.gsub(/-/, ' ')
    end

    def to_param
      id
    end

    def attributes
      {
        id: id,
        text: text
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

