class Comment < ActiveRecord::Base
  belongs_to :article
  default_scope -> { order(created_at: :desc) }
  validates :body, presence: true, length: { maximum: 500 }
end
