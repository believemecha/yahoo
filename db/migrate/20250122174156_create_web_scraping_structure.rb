class CreateWebScrapingStructure < ActiveRecord::Migration[7.0]
  def change
    create_table :scraping_jobs do |t|
      t.string :base_url, null: false
      t.integer :nest_depth
      t.string :status
      t.timestamps
    end

    create_table :scraped_pages do |t|
      t.references :scraping_job, null: false, foreign_key: true
      t.string :url, null: false
      t.text :content
      t.integer :depth, null: false
      t.timestamps
    end

    create_table :page_links do |t|
      t.references :source_page, null: false, foreign_key: { to_table: :scraped_pages }
      t.references :target_page, foreign_key: { to_table: :scraped_pages }
      t.string :target_url, null: false
      t.timestamps
    end

    add_index :scraping_jobs, :base_url
    add_index :scraped_pages, [:scraping_job_id, :url], unique: true
    add_index :page_links, [:source_page_id, :target_url], unique: true
  end
end