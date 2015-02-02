class Article < ActiveRecord::Base
  belongs_to :user
  has_many :comments, dependent: :destroy
  default_scope -> { order(updated_at: :desc) }
  validates :user_id,     presence: true
  validates :text,        presence: true
  validates :title,       presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 500 }

  scope :next,     lambda { |updated_at| where('updated_at > ?', updated_at).reorder('updated_at asc') }
  scope :previous, lambda { |updated_at| where('updated_at < ?', updated_at) }

  def next_article
    Article.next(self.updated_at).first
  end

  def previous_article
    Article.previous(self.updated_at).first
  end

  def self.search(query)
    if query.present?
      basic_search(query)
    else
      all
    end
  end

  def self.searchable_language
    'russian'
  end
end
