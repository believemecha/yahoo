class AddMetaImageToScrapedPages < ActiveRecord::Migration[7.0]
  def change
    add_column :scraped_pages, :meta_image, :string
  end
end