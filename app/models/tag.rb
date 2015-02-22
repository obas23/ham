class Tag
  include Model

  def self.create(tag, date=Time.now)
    id = normalize(tag)
    super(id, date)
  end

  def self.retrieve(tag)
    id = normalize(tag)
    super(id)
  end

  def self.search(*args)
    []
  end

  def self.normalize(text)
    text.strip.downcase.gsub(/[^a-z\d-]+/, '-')
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

