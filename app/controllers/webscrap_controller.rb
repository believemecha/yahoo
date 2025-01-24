require 'readability'
require 'open-uri'
require 'nokogiri'

class WebscrapController < ApplicationController
  def index
    @scraping_jobs = ScrapingJob.order(created_at: :desc)
    render :index
  end

  def new
    @scraping_job = ScrapingJob.new
    render :new
  end

  def create
    @scraping_job = ScrapingJob.new(scraping_job_params)
    @scraping_job.status = 'in_progress'
    
    if @scraping_job.save
      # Enqueue the scraping job
      WebScrapingJob.perform_later(@scraping_job.id)
      
      # Redirect to processing page for status updates
      redirect_to process_scraping_webscrap_path(@scraping_job)
    else
      render :new
    end
  end

  def process_scraping
    @scraping_job = ScrapingJob.find(params[:id])
    render :process_scraping
  end

  def start_scraping
    @scraping_job = ScrapingJob.find(params[:id])
    
    begin
      scraper = WebscrapService.new(@scraping_job.base_url, nil, @scraping_job.nest_depth)
      scraper.start_scraping
      @scraping_job.update(status: 'completed')
      render json: { 
        status: 'completed', 
        message: 'Scraping completed successfully',
        redirect_url: show_scraping_job_webscrap_index_path(id: @scraping_job.id)
      }
    rescue => e
      @scraping_job.update(status: 'failed')
      render json: { 
        status: 'failed', 
        message: "Scraping failed: #{e.message}",
        redirect_url: webscrap_index_path
      }, status: :unprocessable_entity
    end
  end

  def check_status
    job = ScrapingJob.find(params[:id])
    render json: {
      status: job.status,
      total_pages: job.scraped_pages.count,
      current_depth: job.scraped_pages.maximum(:depth) || 0,
      recent_urls: job.scraped_pages.order(created_at: :desc).limit(5).pluck(:url)
    }
  end

  def destroy
    @scraping_job = ScrapingJob.find(params[:id])
    
    begin
      ActiveRecord::Base.transaction do
        # Delete all associated page links first
        PageLink.where(source_page_id: @scraping_job.scraped_pages.pluck(:id)).delete_all
        PageLink.where(target_page_id: @scraping_job.scraped_pages.pluck(:id)).delete_all
        
        # Delete all scraped pages
        @scraping_job.scraped_pages.delete_all
        
        # Finally delete the job itself
        @scraping_job.destroy
      end
      
      respond_to do |format|
        format.html { redirect_to webscrap_index_path, notice: 'Scraping job was successfully deleted.' }
        format.json { head :no_content }
      end
    rescue => e
      respond_to do |format|
        format.html { redirect_to webscrap_index_path, alert: "Error deleting job: #{e.message}" }
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
    end
  end

  def show_scraping_job
    @scraping_job = ScrapingJob.find(params[:id])
    @scraped_pages = @scraping_job.scraped_pages.includes(:outgoing_links, :incoming_links)
    render :show_scraping_job
  rescue ActiveRecord::RecordNotFound
    redirect_to webscrap_index_path, alert: 'Scraping job not found'
  end

  def view_page
    @page = ScrapedPage.find(params[:id])
    @scraping_job = @page.scraping_job
    @scraped_pages = @scraping_job.scraped_pages.includes(:outgoing_links, :incoming_links)
    render :view_page
  end

  def get_page_content
    page = ScrapedPage.find(params[:id])
    render json: { 
      content: page.content,
      url: page.url 
    }
  end

  def get_page_links
    page = ScrapedPage.find(params[:id])
    outgoing_links = page.outgoing_links.map(&:target_url)
    incoming_links = page.incoming_links.map(&:source_page).compact.map(&:url)
    
    render json: {
      outgoing_links: outgoing_links,
      incoming_links: incoming_links
    }
  end

  private

  def scraping_job_params
    params.require(:scraping_job).permit(:base_url, :nest_depth)
  end
end
