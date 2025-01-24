class AddDetailsToScrapingJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :scraping_jobs, :actual_depth, :integer
    add_column :scraping_jobs, :completed_at, :datetime
    add_column :scraping_jobs, :error_message, :text
  end
end