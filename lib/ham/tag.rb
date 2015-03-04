module Ham
  class Tag < Model

    def self.create(tag)
      id     = to_id(tag)
      text   = to_text(id)
      tokens = to_tokens(text)

      max   = $redis.zrange(set, -1, -1, withscores: true).map(&:last).first || 0
      score  = self.score_for(id) || max + 1

      $redis.zadd(set, score, id)

      tokens.each do |token|
        $redis.sadd("token:#{token}:tags", id)
      end

      (1..(text.length)).each do |chars|
        stub = text[0...chars]
        $redis.zadd("tags:stubs", 0, stub)
      end

      $redis.zadd("tags:stubs", 0, "#{text}*")

      new(id)
    end

    def self.retrieve(id)
      if id.is_a? Array
        super id.map { |id| to_id(id) }
      else
        super to_id(id)
      end
    end

    def self.search(query)
      return all if query.nil? or query.strip.empty?
      tokens = to_tokens(query)
      return [] if tokens.none?
      sets    = tokens.sort.map { |token| "token:#{token}:tags" }
      results = $redis.sunion(*sets).sort_by(&:length).reverse
      tags    = retrieve(results)
      return tags
    end

    def self.complete(query)
      results  = []
      rangelen = 50
      count    = 50
      start    = $redis.zrank("tags:stubs", query)
      return [] if !start

      while results.length != count
        stubs = $redis.zrange("tags:stubs", start, start + rangelen - 1)
        start += rangelen
        break if !stubs or stubs.length == 0

        stubs.each do |stub|
          minlen = [stub.length, query.length].min
          if stub[0...minlen] != query[0...minlen]
            count = results.count
            break
          end
          if stub[-1..-1] == "*" and results.length != count
            results << stub[0...-1]
          end
        end
      end

      tags = retrieve(results.reverse)
      return tags
    end

    def self.to_tokens(text)
      text.to_s.strip.downcase.split(/[^a-z\d-]+/)
    end

    def self.to_id(text)
      to_tokens(text).join('-')
    end

    def self.to_text(id)
      id.gsub(/-+/, ' ')
    end

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def text
      Tag.to_text(id)
    end

    def to_s
      text
    end

    def to_param
      id
    end

    def gifs
      Gif.retrieve($redis.smembers("tag:#{id}:gifs"))
    end

    def attributes
      {
        id: id,
        text: text
      }
    end
  end
end
