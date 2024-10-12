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
      @token_key = "8089330080:AAF9axFl5p31fcuHoCXujAQE91UICSRM86I"
      @base_url = "https://tgapp-new.onrender.com"
      if Rails.env.development?
        @token_key = "7833696942:AAHFl9xnJ98zrDfp_n5-kIDvAnXlTf0reVM"
        @base_url = "https://66af-103-240-235-85.ngrok-free.app"
      end
    end
  end