class User < ApplicationRecord
  before_save {self.email.downcase!}
  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 255},
                    format: {with: /A[\w+\-.]+\.[a-z]+\z/i },
                    uniqueness: {case_sensitive: false }
  has_secure_password
  
  has_many :favorites
  has_many :already_fav, through: :favorites, source: :micropost
  has_many :microposts #, through: :favorites
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  def favorite(posted)
    self.favorites.find_or_create_by(micropost_id: posted.id)
  end
  
  def unfavorite(posted)
    favorite = self.favorites.find_by(micropost_id: posted.id)
    favorite.destroy if favorite
  end
  
  def already_fav?(posted)
    self.already_fav.include?(posted)
  end
  
  def list_fav
    Micropost.where(id: self.already_fav_ids)
  end
  
end
