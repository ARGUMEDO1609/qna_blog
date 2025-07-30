class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question
  has_many   :likes, as: :likable, dependent: :destroy

  validates :body, presence: true

  # 🔊 Emisiones Turbo (a todos los que ven la pregunta)
  after_create_commit  -> {
    broadcast_prepend_to [question, :answers],
      partial: "answers/answer",
      locals: { answer: self },
      target: "answers"
  }

  after_update_commit  -> {
    broadcast_replace_to [question, :answers],
      partial: "answers/answer",
      locals: { answer: self }
  }

  after_destroy_commit -> {
    broadcast_remove_to [question, :answers]
  }

  def liked_by?(user)
    user && likes.exists?(user_id: user.id)
  end
end
