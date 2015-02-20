class Tag < ActiveRecord::Base
  has_and_belongs_to_many :gifs
  validates :text, presence: true, uniqueness: { case_sensitive: false }

  def self.search(q)
    q = q.to_s
    return [] unless q.length > 2
    where('text like ?', "%#{q}%").
    order("LENGTH(text) ASC, text ASC")
  end

  def text=(text)
    self[:text] = text.to_s.strip.downcase
  end
end

