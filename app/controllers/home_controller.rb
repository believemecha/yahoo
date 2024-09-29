class HomeController < ApplicationController
    
    def index
        # @card_numbers = InboundEmail.where.not(card_number: nil).distinct.pluck(:card_number)
        @otps = InboundEmail.where.not(otp: nil).order(:card_number).order(created_at: :desc)

        if params[:card_number].present?
            @otps = @otps.where(card_number: params[:card_number])
        end
        @otps = @otps.page(params[:page]).per(20)

        # delete the codes
        InboundEmail.where("created_at < ?", 5.minutes.ago).delete_all
    end

    def webhook
        gem 'nokogiri'

        email_content = params[:html]

        summary = params[:summary]

        doc = Nokogiri::HTML(email_content)

        text = doc.text

        card_number_match = text.match(/card ending in (\d{4})/)

        otp_match = text.match(/one-time passcode is (\d{6})/)

        card_number = card_number_match ? card_number_match[1] : nil

        otp = otp_match ? otp_match[1] : nil

        transaction_at_element = doc.at("//p[contains(text(), 'transaction at')]")
        amount_element = doc.at("//p[contains(text(), 'for the amount')]")
        
        transaction_at = if transaction_at_element
          transaction_at_element.text.match(/transaction at (.*?) for the amount/)[1].strip rescue nil
        end
      
        amount = if amount_element
          amount_element.text.match(/for the amount (.*?) on card/)[1].strip rescue nil
        end
      


        subject = params[:subject]
        to_address = params[:toAddress]
        received_time = params[:receivedTime]
        from_address = params[:fromAddress]

        InboundEmail.new(purpose: "#{transaction_at} #{amount}",summary:summary, to_address: to_address,from_address: from_address,content:text,otp: otp,subject: subject,card_number: card_number,meta: params.except(:action,:controller,:home)).save

        render json: { status: true }, status: :ok 
    end

    def abc
        abc = InboundEmail.count
        InboundEmail.all.delete_all
        render json: {message: "Deleted #{abc} records"}
    end
end