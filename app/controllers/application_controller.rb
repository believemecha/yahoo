class ApplicationController < ActionController::Base
    protect_from_forgery
  
    #
    # redirect registered users to a profile page
    # of to the admin dashboard if the user is an administrator
    #

    before_action :set_details

    def after_sign_in_path_for(resource)
        "/"
    end
  
    def authenticate_admin_user!
      redirect_to root_path if (!current_user.present? || !current_user.admin?)
    end

    def destroy_admin_user
        super
    end

    def no_layout
      @no_layout = true
    end

  
    rescue_from SecurityError do |exception|
      redirect_to root_path
    end

    def set_details
      return redirect_to "/missing" if ( params[:action] != "missing" && params[:action] != "console" && KeyValueStore.payment_missing.exists?)

      @token_key = "8150695652:AAH5Kqr8qFvV_iYcaw1wm8r4E8G2ByQ-UUc"
      @base_url = "https://tgapp-new-sul3.onrender.com"
      @admin_chat_id = 7066215318
      @support_chat_link = "https://t.me/telejobsup"
      @chanel_link = "https://t.me/telejobg"
    end
  end
