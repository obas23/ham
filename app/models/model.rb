module Model
  Error = Class.new(StandardError)
  NotFound = Class.new(Error)

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def set
      self.name.pluralize.downcase
    end

    def create(id, date=Time.now)
      score = self.score(id) || date.to_time.to_i
      $redis.zadd(set, score, id)
      new(id)
    end

    def all
      $redis.zrevrange(set, 0, -1).map { |id| new(id) }
    end

    def retrieve(id)
      score = self.score(id)
      raise NotFound if score.nil?
      id = $redis.zrangebyscore(set, score, score).first
      new(id)
    end

    def score(id)
      $redis.zscore(set, id)
    end

    def first
      id = $redis.zrevrangebyscore(set, "+inf", "-inf", limit: [0,1]).first
      retrieve(id)
    end

    def last
      id = $redis.zrangebyscore(set, "-inf", "+inf", limit: [0,1]).first
      retrieve(id)
    end

    def next(id)
      score = self.score(id)
      id = $redis.zrevrangebyscore(set, "(#{score}", "-inf", limit: [0,1]).first
      if id
        retrieve(id)
      else
        first
      end
    end

    def prev(id)
      score = self.score(id)
      id = $redis.zrangebyscore(set, "(#{score}", "+inf", limit: [0,1]).first
      if id
        retrieve(id)
      else
        last
      end
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

end
