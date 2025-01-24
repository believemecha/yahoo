class ScrapedPage < ApplicationRecord
  belongs_to :scraping_job
  
  # Links where this page is the source
  has_many :outgoing_links, class_name: 'PageLink', foreign_key: 'source_page_id'
  
  # Links where this page is the target
  has_many :incoming_links, class_name: 'PageLink', foreign_key: 'target_page_id'
  
  # Pages that link to this page
  has_many :linking_pages, through: :incoming_links, source: :source_page
  
  # Pages that this page links to
  has_many :linked_pages, through: :outgoing_links, source: :target_page
  
  validates :url, presence: true, uniqueness: { scope: :scraping_job_id }
  validates :depth, presence: true, numericality: { greater_than_or_equal_to: 0 }
end 