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
  # @token_key = "8089330080:AAF9axFl5p31fcuHoCXujAQE91UICSRM86I"

  @token_key = "7833696942:AAHFl9xnJ98zrDfp_n5-kIDvAnXlTf0reVM"

  @base_url = "https://tgapp-new.onrender.com"
  if Rails.env.development?
    @base_url = "https://66af-103-240-235-85.ngrok-free.app/"
  end

  webhook_url = "#{@base_url}/webhooks/telegram"

  Telegram::Bot::Client.run(@token_key ) do |bot|
    response = bot.api.set_webhook(url: webhook_url)
    puts "Response: #{response}"
  end
end


# Done! Congratulations on your new bot. You will find it at t.me/TeleJobsBBot. You can now add a description, about section and profile picture for your bot, see /help for a list of commands. By the way, when you've finished creating your cool bot, ping our Bot Support if you want a better username for it. Just make sure the bot is fully operational before you do this.

#   Use this token to access the HTTP API:
#   8150695652:AAH5Kqr8qFvV_iYcaw1wm8r4E8G2ByQ-UUc
#   Keep your token secure and store it safely



#   RAILS_MASTER_KEY = 47e01124eae37b6362b7a4121b37aaae

#   WEB_CONCURRENCY = 2


#   internal
# postgresql://telejob_user:RngqJh2RjizStq8ldLbFcFO54UJfCJta@dpg-cs39a4bv2p9s738vhds0-a/telejob
# external
# postgresql://telejob_user:RngqJh2RjizStq8ldLbFcFO54UJfCJta@dpg-cs39a4bv2p9s738vhds0-a.oregon-postgres.render.com/telejob

# dogxoxdog@gmail.com
# lrVjoQ9RX1JN12iI



def process(email_content)
  gem 'nokogiri'
  doc = Nokogiri::HTML(email_content)

  text = doc.text.gsub("\r\n", " ").gsub(/\s+/, " ").strip

  # Enhanced OTP patterns
  otp_patterns = [
      /\bis\s(\d{6})\b/,                     # Example: "is 323658"
      /\bsigning in\.\s?(\d{6})\b/,          # Example: "signing in. 550569"
      /\bto verify\s(\d{6})\b/,              # Example: "to verify 323658"
      /verification code is\s(\d{6})\b/,     # Example: "verification code is 834422"
      /Enter this verification code:\s?(\d{6})\b/, # Example: "Enter this verification code: 516156"
      /request:\s(\d{6})\b/
  ]

  # Enhanced email pattern
  email_pattern = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/

  # Extract OTP
  otp = nil
  otp_patterns.each do |pattern|
      match = text.match(pattern)
      if match
      otp = match[1]
      break
      end
  end

  # Extract email
  email_matches = text.scan(email_pattern) # Find all email addresses
  email = email_matches.first # Pick the first valid email match
  return [email,otp]
end
