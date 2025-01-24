class ScrapingJob < ApplicationRecord
  has_many :scraped_pages, dependent: :destroy
  
  validates :base_url, presence: true
  validates :nest_depth, presence: true, numericality: { greater_than: 0 }

  # Add a callback to ensure all associated links are cleaned up
  before_destroy :cleanup_links

  private

  def cleanup_links
    # Find all page links associated with this job's pages
    page_ids = scraped_pages.pluck(:id)
    PageLink.where(source_page_id: page_ids).or(PageLink.where(target_page_id: page_ids)).delete_all
  end
end 