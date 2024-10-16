class TelegramWebhooksController < ApplicationController
  # skip_before_action :verify_authenticity_token
  require 'telegram/bot'

  def receive
    message = params['message']
    
    callback_query = params['callback_query']
  
    if message
      chat_id = message.dig('chat', 'id')
      user_name = message.dig('chat', 'first_name')
      reply_to_message_id = message.dig('reply_to_message', 'message_id') # Check if this is a reply

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


      if reply_to_message_id.present? && tg_user.present && tg_user.wallet_message_id.present? && (tg_user.wallet_message_id == reply_to_message_id.to_i)
        tg_user.update_columns(wallet_address: text)
        send_message(chat_id,"Wallet Updated Successfully to Address: <b>#{tg_user.reload.wallet_address}</b>")
        return head :ok
      end

      if tg_user.present? && tg_user.wallet_message_id.present? && (message["message_id"].to_i  == tg_user.wallet_message_id + 1)
        tg_user.update_columns(wallet_address: text)
        send_message(chat_id,"Wallet Updated Successfully to Address: <b>#{tg_user.reload.wallet_address}</b>")
        return head :ok
      end

      if !tg_user.wallet_address.present?
        message = "<b> Please make sure you're familiar with crypto & the wallet address you entered is correct ,before you proceed.
        </b>\n <b>Wallet Address is required before we proceed! </b> \n <b>Minimum Widthdrawl $10 USD </b>"
        send_message(chat_id,message)
        wallet_message_id = send_message(chat_id,"Our default crypto is USDT, on network BEP20. Please reply to me on this message with the wallet address.")
        tg_user.update(wallet_message_id: wallet_message_id) if wallet_message_id.present?
        return head :ok
      end

      case text
      when '/tasks'
        # send_web_app_link("Tasks",chat_id,"#{@base_url}/tasks/available_tasks")
        list_tasks(tg_user)
      when '/start'
        welcome_message = <<~TEXT
        Welcome, <b>#{user_name}</b>!

        Here are the available commands you can use:
        
        - <b>/tasks</b>: View the list of available tasks.
        - <b>/tasks_history</b>: View your task completion history.
        - <b>/enter_wallet</b>: Add or update your wallet address.
        - <b>/profile</b>: View your profile details, including wallet address and total earnings.
        - <b>/contact</b>: Contact Us.

        Join Our Channel for faster updates.\n 
        #{@chanel_link}

        Feel free to explore the commands above!
      TEXT
      send_message(chat_id, welcome_message)
      # send_message(chat_id, "Welcome, #{user_name}! Use /tasks to see available tasks.")
      when '/tasks_history'
        url = "#{@base_url}/tasks_history?user_code=#{tg_user.code}"
        send_web_app_link("Click Here To View History",chat_id,url)
      when "/enter_wallet"
        message = "<b> Please make sure you're familiar with crypto & the wallet address you entered is correct ,before you proceed.
        </b> \n <b>Minimum Widthdrawl $10 USD </b>"
        send_message(chat_id,message)
        wallet_message_id = send_message(chat_id,"Our default crypto is USDT, on network BEP20. Please reply to me on this message with the wallet address.")
        tg_user.update(wallet_message_id: wallet_message_id) if wallet_message_id.present?
      when "/profile"
        profile_message = "Dear <b>#{tg_user.name}</b>,\nYour profile details are as below:\n" \
                  "<b>Name</b>: #{tg_user.name}\n" \
                  "<b>Wallet Address</b>: #{tg_user.wallet_address.present? ? tg_user.wallet_address : '<a href="/enter_wallet">Not Added, Click here to add</a>'}\n" \
                  "<b>Total Earnings</b>: #{tg_user.total_earning.present? ? tg_user.total_earning : 'Not Available'}"

        send_message(chat_id,profile_message)
        url = "#{@base_url}/profile?user_code=#{tg_user.code}"
        send_web_app_link("Click To View Payment History",chat_id,url)
      when "/contact"
        url = @support_chat_link
        send_message(chat_id,"Contact Support at \n #{@support_chat_link}")
      else
        welcome_message = <<~TEXT
        Command Not Recognised
        
        Here are the available commands you can use:
        
        - <b>/tasks</b>: View the list of available tasks.
        - <b>/tasks_history</b>: View your task completion history.
        - <b>/enter_wallet</b>: Add or update your wallet address.
        - <b>/profile</b>: View your profile details, including wallet address and total earnings.
        - <b>/contact</b>: Contact Us.
        
        Join Our Channel for faster updates.\n 
        #{@chanel_link}

        Feel free to explore the commands above!
        TEXT
        send_message(chat_id,welcome_message)
      end
    elsif callback_query
      process_callback_query(callback_query)
    end
  
    head :ok
  end
  
  private

  def send_wallet_input_options(chat_id)
    # Create a custom keyboard with predefined options
    keyboard = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: [
        [Telegram::Bot::Types::KeyboardButton.new(text: 'Send Wallet Address')],
        [Telegram::Bot::Types::KeyboardButton.new(text: 'Cancel')]
      ],
      one_time_keyboard: true,  # Hide keyboard after user picks an option
      resize_keyboard: true      # Fit the keyboard size to screen
    )
  
    send_message_markup(chat_id, "Please choose an option:", keyboard)
  end

  def old_list_tasks(user)
    tasks = TgTask.active.where("tg_tasks.start_time <= ? and tg_tasks.end_time >= ?",Time.zone.now,Time.zone.now)
    if tasks.any?
      tasks.each do |task|
        message = "<b>Task: #{task.name}</b>\n" \
                  "Description: #{task.description}\n" \
                  "Reward: $#{task.cost}\n" \
                  "Submission Type: #{task.submission_type}\n" \
                  "Start Time: #{task.start_time}\n" \
                  "End Time: #{task.end_time}\n"
        
        send_message(user.chat_id, message)
        send_task_buttons(user.chat_id, task)  # Send the button after the message
      end
    else
      send_message(user.chat_id, "No tasks available at the moment.")
    end
  end


  def list_tasks(user)
    tasks = TgTask.active.where("tg_tasks.start_time <= ? and tg_tasks.end_time >= ?",Time.zone.now,Time.zone.now)
    if tasks.any?
      tasks.each do |task|
        early_details(user.chat_id, task)
      end
    else
      send_message(user.chat_id, "No tasks available at the moment.")
    end
  end

  def early_details(chat_id,task)

    Telegram::Bot::Client.run(@token_key) do |bot|
      buttons = [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "Select Task",
          callback_data: "init_task_#{task.id}"
        )
      ]

      keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(
        inline_keyboard: [buttons]
      )
  
      bot.api.send_message(chat_id: chat_id, text: "Task: #{task.name}, Reward: $#{task.cost}", reply_markup: keyboard)
    end
  end

  def view_next_details(chat_id,task)
    message = "<b>Task: #{task.name}</b>\n" \
                  "Description: #{task.description}\n" \
                  "Reward: $#{task.cost}\n"
    send_task_buttons(chat_id, task)         
  end

  def send_task_buttons(chat_id, task)

    show_join = task.is_private

    Telegram::Bot::Client.run(@token_key) do |bot|
      buttons = [
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "Complete Task #{task.name}",
          callback_data: "complete_task_#{task.id}"
        ),
        Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "View Complete Details",
          callback_data: "view_task_#{task.id}"
        )
      ]
  
      if show_join
        buttons << Telegram::Bot::Types::InlineKeyboardButton.new(
          text: "Join Task",
          callback_data: "join_task_#{task.id}"
        )
      end
  
      keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(
        inline_keyboard: [buttons]  # Wrap buttons inside an array
      )
  
      bot.api.send_message(chat_id: chat_id, text: "Choose Below Options.", reply_markup: keyboard)
    end
  end
  

  def process_callback_query(callback_query)
    callback_data = callback_query['data']
    chat_id = callback_query['message']['chat']['id']

    if callback_data.start_with?('complete_task_')
      task_id = callback_data.split('_').last.to_i
      tg_user = TgUser.find_by(chat_id: chat_id)

      task = TgTask.find_by(id: task_id)

      if !task.is_available
        send_message(chat_id, "This Task is not avaiable. Click /tasks to see avaiable tasks")
        return
      end

      if task.is_private
        task_details = TgTaskDetail.find_by(tg_task_id: task.id,tg_user_id: tg_user.id)
        if !task_details.present?
          send_message(chat_id,"Please Join the Task First using the Join Task Button.")
          return
        end
      end


      if task && tg_user
        url = @base_url + "/submitted_tasks?user_code=#{tg_user.code}&task_code=#{task.code}"
        send_web_app_link("Click here to Complete",chat_id,url)
      else
        send_message(chat_id, "Task not found.")
      end
    end

    if callback_data.start_with?('view_task_')
      task_id = callback_data.split('_').last.to_i
      tg_user = TgUser.find_by(chat_id: chat_id)

      task = TgTask.find_by(id: task_id)

      if !task.is_available
        send_message(chat_id, "This Task is not avaiable. Click /tasks to see avaiable tasks")
        return
      end

      if task && tg_user
        message = "<b>Task: #{task.name}</b>\n" \
                  "Description: #{task.description}\n" \
                  "Reward: $#{task.cost}\n" \
                  "Submission Type: #{task.submission_type}\n" \
                  "Start Time: #{task.start_time}\n" \
                  "End Time: #{task.end_time}\n \n Below are the attached images/videos for your reference"
        if task.is_private
          task_details = TgTaskDetail.find_by(tg_task_id: task.id,tg_user_id: tg_user.id)
          if !task_details.present?
            send_message(chat_id,"Please Join the Task First using the Join Task Button.")
            return
          end
          message = message + "\n \n" \
                    "<b>Please use below information</b>\n" \
                    "<b>#{task_details.details}</b>\n\n"
          message = message + "#{(task_details.meta || {}).map {|k,v| "<b>#{k}:</b> #{v}"}.join("\n")}" 
        end          
        send_message(chat_id,message)
        task.links.each do |file_id|
          send_document_with_file_id(file_id,chat_id)
        end
      end
    end

    if callback_data.start_with?("join_task_")
      task_id = callback_data.split('_').last.to_i
      tg_user = TgUser.find_by(chat_id: chat_id)

      task = TgTask.find_by(id: task_id)

      if !task.is_available
        send_message(chat_id, "This Task is not avaiable. Click /tasks to see avaiable tasks")
        return
      end

      task_details = TgTaskDetail.find_by(tg_task_id: task.id,tg_user_id: tg_user.id)

      if task_details.present?
        send_message(chat_id,"You have already joined the task. Please View task details and complete the task by using Complete Task Button")
        return
      end

      tdetails = TgTaskDetail.where(tg_task_id: task.id,tg_user_id: nil).first

      if tdetails.present?
        tdetails.update(tg_user_id: tg_user.id)
      else
        send_message(chat_id,"All Slots Filled for this. Please try after some time.")
        return
      end
      send_message(chat_id,"You have joined the task. Please View task details and complete the task by using Complete Task Button")
    end

    if callback_data.start_with?('init_task_')
      task_id = callback_data.split('_').last.to_i
      tg_user = TgUser.find_by(chat_id: chat_id)

      task = TgTask.find_by(id: task_id)

      if !task.is_available
        send_message(chat_id, "This Task is not avaiable. Click /tasks to see avaiable tasks")
        return
      end

      if task && tg_user
        view_next_details(tg_user.chat_id,task)
      end
    end
    
  end


  def ask_for_submission_details(user, task)
    # Prompt for the first piece of information: description
    sent_message = send_message(user.chat_id, "Please provide a description for completing the task: #{task.name}.")
    user.update_columns(current_task_id: task.id, submission_step: 'description', last_prompt_message_id: sent_message['message_id'])  # Save the current task ID and step for later
  end

  def handle_submission_response(user, response_text, message, reply_to_message_id)
    task = TgTask.find_by(id: user.current_task_id)

    if task
      case user.submission_step
      when 'description'
        if message.dig('reply_to_message', 'message_id') == user.last_prompt_message_id
          description = response_text.strip  # Clean up the response text
          
          # Check for existing submission or create a new one
          submission = TgTaskSubmission.find_or_initialize_by(tg_user: user, tg_task: task)

          # Update the submission description
          submission.description = description
          submission.save! # Save or update the submission
          
          user.update(submission_step: 'file')  # Update to expect a file next
          sent_message = send_message(user.chat_id, "Please send an image or video for completing the task: #{task.name}.")
          user.update(last_prompt_message_id: sent_message['message_id']) # Update the prompt message ID for file request
        end
      when 'file'
        if message.dig('reply_to_message', 'message_id') == user.last_prompt_message_id
          uploaded_file = handle_file_upload(message, task.submission_type)

          if uploaded_file
            # Add file to the uploaded_files array
            submission = TgTaskSubmission.find_by(tg_user: user, tg_task: task)
            submission.uploaded_files << uploaded_file if submission
            submission.save! # Save the updated submission

            send_message(user.chat_id, "Your completion of #{task.name} has been recorded!")
            user.update(current_task_id: nil, submission_step: nil, last_prompt_message_id: nil)  # Reset after submission
          else
            send_message(user.chat_id, "No valid file received. Please send an image or video.")
          end
        end
      end
    else
      send_message(user.chat_id, "No active task submission found.")
    end
  end

  def handle_file_upload(message, submission_type)
    if submission_type == 'image' && message['photo']
      message['photo'].last['file_id'] # Get the largest version of the photo
    elsif submission_type == 'video' && message['video']
      message['video']['file_id'] # Get the video file
    end
  end

  def send_message(chat_id, text)
    Telegram::Bot::Client.run(@token_key) do |bot|
      bot_response = bot.api.send_message(chat_id: chat_id, text: text, parse_mode: 'HTML')
      return bot_response&.message_id # Return the bot response to get the message_id
    end
  end

  def send_message_markup(chat_id, text, reply_markup = nil)
    Telegram::Bot::Client.run(@token_key) do |bot|
      bot.api.send_message(chat_id: chat_id, text: text, parse_mode: 'HTML', reply_markup: reply_markup)
    end
  end

  def send_web_app_link(text,chat_id,url)
    keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: [
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(
            text: text,
            web_app: { url: url }
          )
        ]
      ]
    )

    send_message_markup(chat_id, "Click the button below to open:", keyboard)
  end
end

private

def get_file_url_from_telegram(file_id)
  begin
    uri = URI("https://api.telegram.org/bot#{@token_key}/getFile?file_id=#{file_id}")
    
    response = Net::HTTP.get(uri)
    
    file_info = JSON.parse(response)
    
    if file_info['ok']
      file_path = file_info['result']['file_path']
      if file_path
        file_url = "https://api.telegram.org/file/bot#{@token_key}/#{file_path}"
        file_url
      else
        nil
      end
    else
      nil
    end
  rescue StandardError => e
    logger.error "Error fetching file path: #{e.message}"
    nil
  end
end

def send_document_with_file_id(file_id, chat_id)
  Telegram::Bot::Client.run(@token_key) do |bot|
    # Directly send the document using the existing file_id
    response = bot.api.send_document(chat_id: chat_id, document: file_id)
    return response if response.present?
  end

  nil
end
