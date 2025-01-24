class ExtractContentService

    def initialize(base_url)
        @base_url = base_url
    end

    def process
        result = scrape_url(@base_url)[:content]
        main_content = result.present? ? result[:main_content] : nil
        main_content.present? ? scan_data(main_content) : nil
    end

    private


    def scan_data(text_data)
        gold_prices = {}
        text_data.scan(/(\d+K).*?₹([\d,]+)/) do |carat, price|
            gold_prices[carat] = price.gsub(',', '').to_i
        end
        gold_prices
    end


    def scrape_url(url)
        uri = URI.parse(url)
        
        # Add rate limiting
        sleep(0.5) # Basic rate limiting
        
        # Setup HTTP client with timeout
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.read_timeout = 10
        http.open_timeout = 10
        
        response = http.get(uri.request_uri)
        
        # Check content type
        content_type = response['Content-Type']
        return { content: nil, links: [] } unless content_type&.include?('text/html')
        
        parsed_response = Nokogiri::HTML(response.body)
        
        # Extract structured content
        extracted_content = {
            title: parsed_response.at_css('title')&.text&.strip,
            meta_description: parsed_response.at_css('meta[name="description"]')&.[]('content')&.strip,
            main_content: extract_main_content(parsed_response),
            raw_html: response.body
        }
        
        # Extract all links from the page
        links = parsed_response.css('a').map do |link|
            {
                href: link['href'],
                text: link.text.strip,
                rel: link['rel']
            }
        end.compact
        
        # Filter and clean links
        valid_links = links.select { |link| valid_url?(link[:href]) }
                          .map { |link| clean_url(link[:href]) }
                          .uniq
        
        
        {
            content: extracted_content,
            links: valid_links
        }
    rescue Net::ReadTimeout, Net::OpenTimeout => e
        Rails.logger.error("Timeout error for URL #{url}: #{e.message}")
        { content: nil, links: [], error: "Timeout: #{e.message}" }
    rescue StandardError => e
        Rails.logger.error("Error scraping URL #{url}: #{e.message}")
        { content: nil, links: [], error: e.message }
    end

    def valid_url?(url)
        return false if url.nil? || url.empty?
        return false if url.start_with?('#', 'mailto:', 'tel:', 'javascript:', 'whatsapp:')
        return false if url.end_with?('.pdf', '.jpg', '.png', '.gif') # Skip direct file links
        
        uri = URI.parse(url)
        # Check if the URL is within the same domain
        uri.host.nil? || uri.host.include?(@base_url)
    rescue URI::InvalidURIError
        false
    end

    def clean_url(url)
        uri = URI.parse(url)
        return url if uri.host  # Already absolute URL
        
        # Convert relative to absolute URL
        cleaned_url = URI.join(@base_url, url).to_s
        # Remove URL fragments and query parameters for better deduplication
        cleaned_url.split('#').first.split('?').first
    rescue URI::InvalidURIError
        url
    end

    def extract_main_content(doc)
        # First remove unwanted elements
        remove_unwanted_elements(doc)
        
        # Try to find main content using common selectors in order of likelihood
        content = doc.at_css([
            'article',                    # Most likely to contain main content
            'main',                       # HTML5 main content tag
            '#content',                   # Common content IDs
            '#main-content',
            '.content',                   # Common content classes
            '.main-content',
            '.post-content',
            '.article-content',
            '[role="main"]',             # ARIA role for main content
            '.entry-content'
        ].join(', '))
        
        if content
            clean_text(content)
        else
            # Fallback: Use the body but try to extract meaningful content
            body = doc.at_css('body')
            clean_text(body)
        end
    end

    def remove_unwanted_elements(doc)
        # Remove elements that usually don't contain main content
        selectors_to_remove = [
            'nav',                  # Navigation elements
            'header',              # Page header
            'footer',              # Page footer
            '.nav',                # Navigation classes
            '.navigation',
            '.menu',
            '.sidebar',            # Sidebars
            '.comments',           # Comment sections
            '.advertisement',      # Ads
            '.ad',
            '#nav',
            '#header',
            '#footer',
            '#sidebar',
            'script',              # Scripts
            'style',               # Style tags
            'link',                # Link tags
            'iframe',              # Iframes
            '.social-share',       # Social sharing buttons
            '.related-posts'       # Related content
        ]

        doc.css(selectors_to_remove.join(', ')).each(&:remove)
    end

    def clean_text(element)
        return '' unless element

        # Get text content
        text = element.text
            .gsub(/\s+/, ' ')           # Replace multiple spaces with single space
            .gsub(/\n+/, "\n")          # Replace multiple newlines with single newline
            .gsub(/\t+/, ' ')           # Replace tabs with spaces
            .strip

        # Remove any remaining HTML entities
        text = CGI.unescapeHTML(text)

        # Remove very short lines (likely menu items or buttons)
        lines = text.split("\n").reject { |line| line.strip.length < 20 }
        
        # Join lines back together
        lines.join("\n").strip
    end

    def extract_meta_image(doc)
        # Try different meta image tags in order of preference
        image_url = doc.at_css([
            'meta[property="og:image"]',           # Open Graph
            'meta[name="twitter:image"]',          # Twitter Cards
            'meta[property="og:image:secure_url"]',
            'meta[itemprop="image"]',              # Schema.org
            'link[rel="image_src"]'                # Legacy
        ].join(', '))&.[]('content', 'href')

        # If no meta image found, try to find first significant image
        if image_url.nil?
            image_element = doc.at_css('img[src*="/"][width="600"], img[src*="/"][data-width="600"]')
            image_url = image_element&.[]('src')
        end

        # Clean and validate the URL if found
        if image_url
            begin
                cleaned_url = clean_url(image_url)
                URI.parse(cleaned_url).to_s
            rescue URI::InvalidURIError
                nil
            end
        end
    end
end
