class Tag < ActiveRecord::Base
  has_and_belongs_to_many :gifs
  validates :text, presence: true, uniqueness: { case_sensitive: false }
end

