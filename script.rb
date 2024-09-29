owner_id = User.find(email:"lbsingh732196@gmail.com").id
100.times do |i|
    School.create(
      name: Faker::Address.city,
      location: Faker::Address.city,
      owner_id: owner_id,
      status: rand(0..2),
      meta: { website: Faker::Internet.url }
    )
  end


  @otps_grouped_by_card = InboundEmail.where.not(otp: nil).order(:card_number).group(:card_number).pluck(:card_number, :otp, :to_address, :from_address, :subject, :created_at)



  uri = URI.parse('https://app.cityphonebook.com/master_process.php?task=save_contact')

header = {
  'authority' => 'app.cityphonebook.com',
  'accept' => '*/*',
  'accept-language' => 'en-GB,en-US;q=0.9,en;q=0.8',
  'content-type' => 'application/x-www-form-urlencoded; charset=UTF-8',
  'cookie' => '_ga=GA1.2.629356882.1716094981; _ga_9Q6H0QETRF=GS1.2.1716105897.2.0.1716105897.60.0.0; PHPSESSID=0h0vi7ge2rp43amis0rslfcjuk; user_mobile=7321965118; user_id=dXNlcl9pZD0xNjUmc2FsdD1WS09ZOTZQTkdJVEhBNUMz; auth_token=3f0a65471c9114887e49569116da7b89192b5bca63e6fb86cb323b6523b79895',
  'origin' => 'https://app.cityphonebook.com',
  'referer' => 'https://app.cityphonebook.com/contact.php?cat_id=47&location_id=42',
  'sec-ch-ua' => '"Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"',
  'sec-ch-ua-mobile' => '?0',
  'sec-ch-ua-platform' => '"Linux"',
  'sec-fetch-dest' => 'empty',
  'sec-fetch-mode' => 'cors',
  'sec-fetch-site' => 'same-origin',
  'user-agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36',
  'x-requested-with' => 'XMLHttpRequest'
}

data = 'profile_id=1&viewed_by=165&type=call'

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri.request_uri, header)
request.body = data

response = http.request(request)

puts response.body




require 'net/http'
require 'uri'

# Define the base URI and headers
uri = URI.parse('https://app.cityphonebook.com/master_process.php?task=save_contact')

header = {
  'authority' => 'app.cityphonebook.com',
  'accept' => '*/*',
  'accept-language' => 'en-GB,en-US;q=0.9,en;q=0.8',
  'content-type' => 'application/x-www-form-urlencoded; charset=UTF-8',
  'cookie' => '_ga=GA1.2.629356882.1716094981; _ga_9Q6H0QETRF=GS1.2.1716105897.2.0.1716105897.60.0.0; PHPSESSID=0h0vi7ge2rp43amis0rslfcjuk; user_mobile=7321965118; user_id=dXNlcl9pZD0xNjUmc2FsdD1WS09ZOTZQTkdJVEhBNUMz; auth_token=3f0a65471c9114887e49569116da7b89192b5bca63e6fb86cb323b6523b79895',
  'origin' => 'https://app.cityphonebook.com',
  'referer' => 'https://app.cityphonebook.com/contact.php?cat_id=47&location_id=42',
  'sec-ch-ua' => '"Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"',
  'sec-ch-ua-mobile' => '?0',
  'sec-ch-ua-platform' => '"Linux"',
  'sec-fetch-dest' => 'empty',
  'sec-fetch-mode' => 'cors',
  'sec-fetch-site' => 'same-origin',
  'user-agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36',
  'x-requested-with' => 'XMLHttpRequest'
}

# List of profile_ids to loop through
profile_ids = (1..10000).to_a

# Create a new HTTP object for making the requests
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true


result = []
# Loop through each profile_id and make the request
profile_ids.each do |profile_id|
  data = "profile_id=#{profile_id}&viewed_by=165&type=call"
  
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = data
  
  response = http.request(request)
  
  result << response.body
end

abc = result.map {|x| JSON.parse(x)}

d = abc.map {|x| [x["id"],x["url"].split("tel:")[1]]}


message = d.map {|x| "ID: #{x.first}, Number: #{x.second}"}.join("\n")



require 'open-uri'
require 'tempfile'

# Define the URL
url = "https://offerplant.com/img/logo.png"

file = nil
# Fetch the content from the URL and create a temporary file
Tempfile.create(['image', '.png']) do |temp_file|
  # Open the URL and write the content to the temp file
  URI.open(url) do |uri|
    temp_file.binmode # Ensure the file is in binary mode
    temp_file.write(uri.read)
    temp_file.rewind # Move back to the beginning of the file
    file = temp_file
    # Use the temporary file
    puts "Temporary file created at: #{temp_file.path}"

    # Example: Read back the file content (if needed)
    # puts temp_file.read
  end

  # The temporary file will be deleted automatically when this block ends
end


require 'telegram/bot'

def set_telegram_webhook
  @token_key = "8089330080:AAF9axFl5p31fcuHoCXujAQE91UICSRM86I"
  webhook_url = "https://tg-mini-ruby.onrender.com/webhooks/telegram"

  Telegram::Bot::Client.run(@token_key ) do |bot|
    response = bot.api.set_webhook(url: webhook_url)
    puts "Response: #{response}"
  end
end

