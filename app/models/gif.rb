class Gif < ActiveRecord::Base
  has_and_belongs_to_many :tags
  validates :id, presence: true, uniqueness: { case_sensitive: false }
  default_scope { order('created_at DESC') }

  def url
    "http://i.imgur.com/#{id}.gif"
  end

  def thumbnail_url
    "http://i.imgur.com/#{id}b.gif"
  end
end

