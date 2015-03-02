class Model
  Error = Class.new(StandardError)
  NotFound = Class.new(Error)

  def self.set
    self.name.downcase + 's'
  end

  def self.create(id)
    score = self.score_for(id) || max + 1
    $redis.zadd(set, score, id)
    new(id)
  end

  def self.all
    $redis.zrevrange(set, 0, -1).map { |id| new(id) }
  end

  def self.retrieve(id)
    score = self.score_for(id)
    raise NotFound if score.nil?
    id = $redis.zrangebyscore(set, score, score).first
    new(id)
  end

  def self.score_for(id)
    $redis.zscore(set, id)
  end

  def self.max
    $redis.zrange(set, -1, -1, withscores: true).map(&:last).first || 0.0
  end

  def self.first
    id = $redis.zrevrangebyscore(set, "+inf", "-inf", limit: [0,1]).first
    retrieve(id)
  end

  def self.last
    id = $redis.zrangebyscore(set, "-inf", "+inf", limit: [0,1]).first
    retrieve(id)
  end

  def self.next(id)
    score = self.score_for(id)
    id = $redis.zrevrangebyscore(set, "(#{score}", "-inf", limit: [0,1]).first
    if id
      retrieve(id)
    else
      first
    end
  end

  def self.prev(id)
    score = self.score_for(id)
    id = $redis.zrangebyscore(set, "(#{score}", "+inf", limit: [0,1]).first
    if id
      retrieve(id)
    else
      last
    end
  end

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def ==(other)
    id == other.id
  end

  def next
    self.class.next(id)
  end

  def prev
    self.class.prev(id)
  end

  def to_json(*a)
    as_json.to_json(*a)
  end

  def as_json(*a)
    attributes
  end
end
