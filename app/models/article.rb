class Article < ActiveRecord::Base
  has_many :comments, dependent: :destroy
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 500 }

  scope :next, lambda { |updated_at| where('updated_at > ?', updated_at).order('updated_at ASC') }
  scope :previous, lambda { |updated_at| where('updated_at < ?', updated_at).order('updated_at DESC') }

  def next_article
    Article.next(self.updated_at).first
  end

  def previous_article
    Article.previous(self.updated_at).first
  end

end
