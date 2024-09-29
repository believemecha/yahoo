class TelegramWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  require 'telegram/bot'

  def receive
    base_url = "https://ecda-103-240-233-40.ngrok-free.app"
    message = params['message']
    callback_query = params['callback_query']

    if message
      chat_id = message.dig('chat', 'id')
      user_name = message.dig('chat', 'first_name')

      # Check or create user
      tg_user = TgUser.find_or_create_by(chat_id: chat_id) do |user|
        user.name = user_name
        user.blocked = false
      end

      if tg_user.blocked
        send_message(chat_id, "You are blocked from using this service.")
        return head :ok
      end

      text = message['text']

      case text
      when '/tasks'
        send_web_app_link(chat_id, "#{base_url}/tasks")
      when '/pending_tasks'
        send_web_app_link(chat_id, "#{base_url}/pending_tasks")
      when '/completed_tasks'
        send_web_app_link(chat_id, "#{base_url}/completed_tasks")
      when '/start'
        send_message(chat_id, "Welcome, #{user_name}! Use /tasks to see available tasks.")
      else
        send_message(chat_id, "Command not recognized. Use /tasks to see available tasks.")
      end
    elsif callback_query
      process_callback_query(callback_query)
    end

    head :ok
  end

  private

  def send_web_app_link(chat_id, url)
    keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: [
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(
            text: "View Tasks",
            web_app: { url: url } # Change to web_app type
          )
        ]
      ]
    )

    send_message(chat_id, "Click the button below to open the web app:", keyboard)
  end

  def process_callback_query(callback_query)
    callback_data = callback_query['data']
    chat_id = callback_query['message']['chat']['id']

    # Handle any callback queries here if needed
  end

  def send_message(chat_id, text, reply_markup = nil)
    Telegram::Bot::Client.run(@token_key) do |bot|
      bot.api.send_message(chat_id: chat_id, text: text, parse_mode: 'HTML', reply_markup: reply_markup)
    end
  end
end
