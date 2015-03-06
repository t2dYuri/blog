class Comment < ActiveRecord::Base
  belongs_to :article
  belongs_to :user

  default_scope -> { order(created_at: :desc) }

  validates :body, presence: true, length: { maximum: 500 }
  validates :user_id, presence: true
end
