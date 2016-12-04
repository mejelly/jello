class Article < ApplicationRecord
  has_many :translations
  validates :title, presence: true, allow_blank: false
  validates :content, presence: true, allow_blank: false
end
