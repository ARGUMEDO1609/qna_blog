class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question
  has_many   :likes, as: :likable, dependent: :destroy

  validates :body, presence: true

  def liked_by?(user)
    user && likes.exists?(user_id: user.id)
  end
end

