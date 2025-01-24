class EnhanceScrapedPages < ActiveRecord::Migration[7.0]
  def change
    add_column :scraped_pages, :title, :string
    add_column :scraped_pages, :meta_description, :text
    add_column :scraped_pages, :main_content, :text
    add_column :scraped_pages, :raw_html, :text
    add_column :scraped_pages, :status, :string, default: 'pending'
    
    # If you had a content column before, you might want to remove it
    # remove_column :scraped_pages, :content, :text
  end
end