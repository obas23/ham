class Tag
  include Model

  def self.create(tag, date=Time.now)
    id     = normalize(tag)
    tokens = tokenize(tag)
    score  = self.score_for(id) || date.to_time.to_i
    $redis.zadd(set, score, id)

    tokens.each do |token|
      set = "token:#{token}:tags"
      $redis.sadd(set, id)
    end

    new(id)
  end

  def self.retrieve(tag)
    id = normalize(tag)
    super(id)
  end

  def self.search(query)
    tokens = tokenize(query)
    return [] if tokens.none?
    sets    = tokens.sort.map { |token| "token:#{token}:tags" }
    results = $redis.sunion(*sets).sort_by(&:length).reverse
    tags    = results.map { |tag| new(tag) }
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

  def to_s
    Tag.denormalize(id)
  end

  def gifs
    $redis.smembers("tag:#{id}:gifs").map { |g| Gif.new(g) }
  end
end

