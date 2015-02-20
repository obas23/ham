class Gif < ActiveRecord::Base
  has_and_belongs_to_many :tags

  validates :id, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order('created_at DESC') }

  def self.search(q)
    joins(:tags).merge(Tag.search(q))
  end

  def self.next(date)
    where("created_at < ?", date).reorder('created_at DESC').limit(1).first or first
  end

  def self.prev(date)
    where("created_at > ?", date).reorder('created_at ASC').limit(1).first or last
  end

  def tag!(text)
    tag = Tag.find_or_create_by! text: text.to_s.strip.downcase
    tags << tag unless tags.include?(tag)
  end

  def untag!(tag_id)
    tag = tags.find(tag_id)
    tags.delete(tag)
  end

  def url
    "http://i.imgur.com/#{id}.gif"
  end

  def thumbnail_url
    "http://i.imgur.com/#{id}b.gif"
  end

  def next
    Gif.next(created_at)
  end

  def prev
    Gif.prev(created_at)
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

