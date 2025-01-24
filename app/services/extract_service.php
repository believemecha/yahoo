<?php
error_reporting(E_ALL); // Report all PHP errors
ini_set('display_errors', '1'); // Display errors on the browser

class ExtractContentService {
    private $base_url;

    public function __construct($base_url) {
        $this->base_url = $base_url;
    }

    public function process() {
        $scrape_result = $this->scrape_url($this->base_url);
        echo "Extracted Text Content:\n";
        echo "------------------------\n";
        if (!empty($scrape_result['content']['main_content'])) {
            echo $scrape_result['content']['main_content'] . "\n";
        } else {
            echo "No content extracted\n";
        }
        
        return $this->scan_data($scrape_result['content']['main_content'] ?? '');
    }

    private function scan_data($text_data) {
        $gold_prices = array();
        preg_match_all('/(\d+K).*?₹([\d,]+)/', $text_data, $matches, PREG_SET_ORDER);
        foreach ($matches as $match) {
            $gold_prices[$match[1]] = (int)str_replace(',', '', $match[2]);
        }
        return $gold_prices;
    }

    private function scrape_url($url) {
        $uri = parse_url($url);
        
        // Add rate limiting
        usleep(500000); // Basic rate limiting - 0.5 seconds
        
        // Setup HTTP client with timeout
        $context = stream_context_create([
            'http' => [
                'timeout' => 10,
                'follow_location' => true
            ],
            'ssl' => [
                'verify_peer' => false,
                'verify_peer_name' => false
            ]
        ]);

        try {
            $response = file_get_contents($url, false, $context);
            if ($response === false) {
                throw new Exception("Failed to fetch URL");
            }

            // Get headers
            $headers = $http_response_header;
            $content_type = '';
            foreach ($headers as $header) {
                if (stripos($header, 'Content-Type:') !== false) {
                    $content_type = $header;
                    break;
                }
            }

            if (!stripos($content_type, 'text/html')) {
                return ['content' => null, 'links' => []];
            }

            // Use DOMDocument for HTML parsing
            $doc = new DOMDocument();
            @$doc->loadHTML($response, LIBXML_NOERROR);
            $xpath = new DOMXPath($doc);

            // Extract structured content
            $extracted_content = [
                'title' => $this->get_element_text($xpath, '//title'),
                'meta_description' => $this->get_meta_description($xpath),
                'main_content' => $this->extract_main_content($doc, $xpath),
                'raw_html' => $response
            ];

            // Extract all links
            $links = [];
            $link_elements = $xpath->query('//a');
            foreach ($link_elements as $link) {
                $href = $link->getAttribute('href');
                $text = trim($link->textContent);
                $rel = $link->getAttribute('rel');
                
                if ($href) {
                    $links[] = [
                        'href' => $href,
                        'text' => $text,
                        'rel' => $rel
                    ];
                }
            }

            // Filter and clean links
            $valid_links = array_unique(
                array_map(
                    [$this, 'clean_url'],
                    array_filter(
                        array_column($links, 'href'),
                        [$this, 'valid_url']
                    )
                )
            );

            return [
                'content' => $extracted_content,
                'links' => $valid_links
            ];

        } catch (Exception $e) {
            error_log("Error scraping URL $url: " . $e->getMessage());
            return [
                'content' => null,
                'links' => [],
                'error' => $e->getMessage()
            ];
        }
    }

    private function valid_url($url) {
        if (empty($url)) return false;
        if (preg_match('/^(#|mailto:|tel:|javascript:|whatsapp:)/', $url)) return false;
        if (preg_match('/\.(pdf|jpg|png|gif)$/i', $url)) return false;

        try {
            $uri = parse_url($url);
            return empty($uri['host']) || strpos($uri['host'], $this->base_url) !== false;
        } catch (Exception $e) {
            return false;
        }
    }

    private function clean_url($url) {
        try {
            $uri = parse_url($url);
            if (!empty($uri['host'])) {
                return $url;
            }

            // Convert relative to absolute URL
            $base = rtrim($this->base_url, '/');
            $url = ltrim($url, '/');
            $cleaned_url = "$base/$url";

            // Remove fragments and query parameters
            $parts = explode('#', $cleaned_url);
            $parts = explode('?', $parts[0]);
            return $parts[0];

        } catch (Exception $e) {
            return $url;
        }
    }

    private function extract_main_content($doc, $xpath) {
        // Remove unwanted elements
        $this->remove_unwanted_elements($doc);

        // Try to find main content using common selectors
        $selectors = [
            '//article',
            '//main', 
            '//*[@id="content"]',
            '//*[@id="main-content"]',
            '//*[contains(@class,"content")]',
            '//*[contains(@class,"main-content")]',
            '//*[contains(@class,"post-content")]',
            '//*[contains(@class,"article-content")]',
            '//*[@role="main"]',
            '//*[contains(@class,"entry-content")]'
        ];

        $content = null;
        foreach ($selectors as $selector) {
            $element = $xpath->query($selector)->item(0);
            if ($element) {
                $content = $element;
                break;
            }
        }

        if (!$content) {
            $content = $xpath->query('//body')->item(0);
        }

        return $this->clean_text($content ? $content->textContent : '');
    }

    private function remove_unwanted_elements($doc) {
        $selectors = [
            'nav', 'header', 'footer', '.nav', '.navigation',
            '.menu', '.sidebar', '.comments', '.advertisement',
            '.ad', '#nav', '#header', '#footer', '#sidebar',
            'script', 'style', 'link', 'iframe',
            '.social-share', '.related-posts'
        ];

        $xpath = new DOMXPath($doc);
        foreach ($selectors as $selector) {
            $elements = $xpath->query("//*[contains(@class,'".str_replace('.', '', $selector)."')] | //*[@id='".str_replace('#', '', $selector)."'] | //".str_replace(['.', '#'], '', $selector));
            foreach ($elements as $element) {
                $element->parentNode->removeChild($element);
            }
        }
    }

    private function clean_text($text) {
        if (empty($text)) return '';

        // Clean up whitespace
        $text = preg_replace('/\s+/', ' ', $text);
        $text = preg_replace('/\n+/', "\n", $text);
        $text = preg_replace('/\t+/', ' ', $text);
        $text = trim($text);

        // Decode HTML entities
        $text = html_entity_decode($text);

        // Remove short lines
        $lines = array_filter(
            explode("\n", $text),
            function($line) {
                return strlen(trim($line)) >= 20;
            }
        );

        return implode("\n", $lines);
    }

    private function get_element_text($xpath, $query) {
        $element = $xpath->query($query)->item(0);
        return $element ? trim($element->textContent) : '';
    }

    private function get_meta_description($xpath) {
        $meta = $xpath->query('//meta[@name="description"]')->item(0);
        return $meta ? trim($meta->getAttribute('content')) : '';
    }

    private function extract_meta_image($doc) {
        $xpath = new DOMXPath($doc);
        
        // Try different meta image tags
        $selectors = [
            '//meta[@property="og:image"]',
            '//meta[@name="twitter:image"]',
            '//meta[@property="og:image:secure_url"]',
            '//meta[@itemprop="image"]',
            '//link[@rel="image_src"]'
        ];

        $image_url = null;
        foreach ($selectors as $selector) {
            $element = $xpath->query($selector)->item(0);
            if ($element) {
                $image_url = $element->getAttribute('content') ?: $element->getAttribute('href');
                if ($image_url) break;
            }
        }

        // Fallback to first significant image
        if (!$image_url) {
            $img = $xpath->query('//img[contains(@src,"/")][@width="600" or @data-width="600"]')->item(0);
            if ($img) {
                $image_url = $img->getAttribute('src');
            }
        }

        // Clean and validate URL
        if ($image_url) {
            try {
                $cleaned_url = $this->clean_url($image_url);
                return filter_var($cleaned_url, FILTER_VALIDATE_URL) ? $cleaned_url : null;
            } catch (Exception $e) {
                return null;
            }
        }

        return null;
    }
}



$base_url = 'https://bullions.co.in/';
$extractor = new ExtractContentService($base_url);

// Process the URL and get the results
$results = $extractor->process();

// Print the results
print_r($results);