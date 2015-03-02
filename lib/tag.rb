class Tag < Model

  def self.create(tag)
    id     = normalize(tag)
    text   = denormalize(id)
    tokens = tokenize(tag)

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

  def self.retrieve(tag)
    id = normalize(tag)
    super(id)
  end

  def self.search(query)
    return all if query.nil? or query.strip.empty?
    tokens = tokenize(query)
    return [] if tokens.none?
    sets    = tokens.sort.map { |token| "token:#{token}:tags" }
    results = $redis.sunion(*sets).sort_by(&:length).reverse
    tags    = results.map { |tag| retrieve(tag) }
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

    tags = results.reverse.map { |tag| retrieve(tag) }
    return tags
  end

  def self.tokenize(text)
    text.to_s.strip.downcase.split(/[^a-z\d-]+/)
  end

  def self.normalize(text)
    tokens = tokenize(text)
    tokens.join('-')
  end

  def self.denormalize(text)
    text.gsub(/-+/, ' ')
  end

  attr_reader :id, :text

  def initialize(id)
    @id = Tag.normalize(id)
    @text = Tag.denormalize(id)
  end

  def to_s
    text
  end

  def to_param
    id
  end

  def gifs
    $redis.smembers("tag:#{id}:gifs").map { |g| Gif.retrieve(g) }
  end

  def attributes
    {
      id: id,
      text: text
    }
  end
end

