class PageLink < ApplicationRecord
  belongs_to :source_page, class_name: 'ScrapedPage'
  belongs_to :target_page, class_name: 'ScrapedPage', optional: true
  
  validates :target_url, presence: true
  validates :source_page_id, uniqueness: { scope: :target_url }
end 