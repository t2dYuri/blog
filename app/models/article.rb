class Article < ActiveRecord::Base
  belongs_to :user
  has_many :comments, dependent: :destroy
  # default_scope -> { order(updated_at: :desc) }
  validates :user_id,     presence: true
  validates :text,        presence: true
  validates :title,       presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 500 }

  scope :next,     lambda { |updated_at| where('updated_at > ?', updated_at).order('updated_at asc') }
  scope :previous, lambda { |updated_at| where('updated_at < ?', updated_at).order('updated_at desc') }

  def next_article
    Article.next(self.updated_at).first
  end

  def previous_article
    Article.previous(self.updated_at).first
  end

end
