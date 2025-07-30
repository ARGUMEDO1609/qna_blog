class Question < ApplicationRecord
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy

  validates :title, presence: true, length: { maximum: 160 }
  validates :body,  presence: true

  def liked_by?(user)
    user && likes.exists?(user_id: user.id)
  end
end

