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

  
    rescue_from SecurityError do |exception|
      redirect_to root_path
    end

    def set_details
      @token_key = "8089330080:AAF9axFl5p31fcuHoCXujAQE91UICSRM86I"
      @base_url = "https://tgapp-new.onrender.com"
      if Rails.env.development?
        @base_url = "https://bca0-150-242-86-79.ngrok-free.app"
      end
    end
  end