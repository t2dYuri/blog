class Comment < ActiveRecord::Base
  belongs_to :article
  default_scope -> { order(created_at: :desc) }
  # validates :commenter, presence: true, length: { maximum: 40 }
  validates :body, presence: true, length: { maximum: 500 }
end
