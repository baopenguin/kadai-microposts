class Micropost < ApplicationRecord
  belongs_to :user
  has_many :favorites
  has_many :fav_user, through: :favorites, source: :user
  # has_many :user, through: :favorites
  
  validates :content, presence: true, length: {maximum: 255 }
end
