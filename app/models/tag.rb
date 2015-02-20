class Tag < ActiveRecord::Base
  has_and_belongs_to_many :gifs
  validates :text, presence: true, uniqueness: { case_sensitive: false }

  def text=(text)
    self[:text] = text.to_s.downcase
  end
end

