class WebScrapingJob < ApplicationJob
  queue_as :default

  def perform(scraping_job_id)
    scraping_job = ScrapingJob.find(scraping_job_id)
    
    begin
      scraper = WebscrapService.new(scraping_job.base_url, nil, scraping_job.nest_depth)
      scraper.start_scraping(scraping_job_id)
    rescue => e
      scraping_job.update(status: 'failed')
      Rails.logger.error "Scraping failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
  end
end 