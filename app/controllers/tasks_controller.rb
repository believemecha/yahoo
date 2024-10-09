# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update,:create_or_edit,:new,:add_files]

  before_action :verify_access, except: [:complete_task,:submitted_tasks,:tasks_history,:update_complete_task,:profile]
  require 'telegram/bot'

  def index
    @tasks = TgTask.order(created_at: :desc)
  end

  def show
    @submissions = TgTaskSubmission.where(tg_task_id: @task.id)
  end

  def new
    @task = @task.present? ? @task : TgTask.new
  end

  def create
    @task = TgTask.new(task_params)
    if @task.save
      redirect_to tasks_path, notice: 'Task was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to task_path(@task), notice: 'Task was successfully updated.'
    else
      render :edit
    end
  end

  def create_or_edit
    if @task.try(:id).present? # Check if task already exists (for editing)
      if @task.update(task_params)
        render json: { success: true, message: 'Task updated successfully.' }
      else
        render json: { success: false, errors: @task.errors.full_messages }
      end
    else
      @task = TgTask.new(task_params)
      if @task.save
        render json: { success: true, message: 'Task created successfully.' }
      else
        render json: { success: false, errors: @task.errors.full_messages }
      end
    end
  end

  def add_files

  end

  def upload_file_to_task

    @task = TgTask.find(params[:id])
    file_ids = @task.links


    if params[:files].present?
      params[:files].each do |file|
        if file.present?
          file_id = upload_file_to_telegram(file)
          file_ids << file_id if file_id
        end
      end
    end

    # You can store the file_ids in your TgTask or TgSubmission model if necessary
    # For example, if you have a field to store multiple file_ids in TgTask:
    @task.update(links: file_ids)

    redirect_to "/tasks", notice: 'Files uploaded successfully to Telegram.'
  end

  def submissions
    @submissions = TgTaskSubmission.includes(:tg_user)
    if params[:task_id].present?
      @task = TgTask.find_by(id: params[:task_id])
      @submissions = @submissions.where(tg_task_id: @task.try(:id))
    end

    if params[:paid].present?
      @submissions = @submissions.where(is_paid: ActiveModel::Type::Boolean.new.cast(params[:paid]))
    end
  
    # Filter by status
    if params[:status].present?
      @submissions = @submissions.where(status: params[:status])
    end
  
    # Filter by user_id
    if params[:user_id].present?
      @submissions = @submissions.where(tg_user_id: params[:user_id])
    end

    @submissions = @submissions.page(params[:page] || 1).per(50)
  end

  def old_upload_file_to_telegram(file,chat_id = nil)
    Telegram::Bot::Client.run(@token_key) do |bot|
      chat_id = chat_id || 954015423
  
      if file.present?
        if file.content_type.start_with?('image')
          response = bot.api.send_photo(chat_id: chat_id, photo: Faraday::UploadIO.new(file.path, file.content_type))
          return response[:photo]&.first&.file_id if response.present?
        elsif file.content_type.start_with?('video')
          response = bot.api.send_video(chat_id: chat_id, video: Faraday::UploadIO.new(file.path, file.content_type))
          return response[:video]&.file_id if response.present?
        end
      end
    end
    nil
  end 
  
  def upload_file_to_telegram(file, chat_id = nil)
    Telegram::Bot::Client.run(@token_key) do |bot|
      chat_id = chat_id || 954015423
  
      if file.present?
        # Send file as a document to avoid compression
        response = bot.api.send_document(chat_id: chat_id, document: Faraday::UploadIO.new(file.path, file.content_type))
        return response[:document]&.file_id if response.present?
      end
    end
    nil
  end

  def complete_task
    @task = TgTask.find_by(code: params[:task_code])
    @user = TgUser.find_by(code: params[:user_code])

    submission_code = params[:submission_code]

    return render json: {success: false, message: "Invalid Request"} unless @task.present? && @user.present?

    @task_submission = TgTaskSubmission.find_by(code: submission_code)

    if @task_submission.present? && ( @task_submission.tg_user_id != @user.id || @task_submission.tg_task_id != @task.id)
      return render json: {success: false, message: "Invalid Request"} unless @task.present? && @user.present?
    end
    
    @is_new_submission = @task_submission.nil?
  end

  def submitted_tasks
    @task = TgTask.find_by(code: params[:task_code])
    @user = TgUser.find_by(code: params[:user_code])
    
    return render json: {success: false, message: "Invalid Request"} unless @task.present? && @user.present?
    
    @submissions = TgTaskSubmission.where(tg_user_id: @user.try(:id), tg_task_id: @task.try(:id)).order(created_at: :desc)
  end

  def tasks_history
    @user = TgUser.find_by(code: params[:user_code])

    return render json: {success: false, message: "Invalid Request"} unless @user.present?
    
    task_ids = TgTaskSubmission.where(tg_user_id: @user.id).select(:tg_task_id).distinct.map {|x| x.tg_task_id}
    @tasks = TgTask.where(id: task_ids)
  end

  def profile
    @user = TgUser.find_by(code: params[:user_code])
    return render json: {success: false, message: "Invalid Request"} unless @user.present?
    @task_submissions = TgTaskSubmission.where(tg_user_id: @user.id,is_paid: true)
  end

  def users
    @users = TgUser.order(created_at: :desc)
    @users = @users.page(params[:page] || 1).per(50)
  end

  def update_complete_task
    @task = TgTask.find_by(code: params[:task_code])
    @user = TgUser.find_by(code: params[:user_code])

    return render json: {success: false, message: "Invalid Request"} unless @task.present? && @user.present?

    submission_code = params[:submission_code]

    @task_submission = TgTaskSubmission.find_by(code: submission_code)

    if @task_submission.present? &&( @task_submission.tg_user_id != @user.id || @task_submission.tg_task_id != @task.id)
      return render json: {success: false, message: "Invalid Request"} unless @task.present? && @user.present?
    end
    
    if !@task_submission.present?
      @task_submission = TgTaskSubmission.new(tg_user_id: @user.try(:id), tg_task_id: @task.try(:id))
      if TgTaskSubmission.where(tg_user_id: @user.try(:id), tg_task_id: @task.try(:id)).count >= @task.maximum_per_user.to_i
        return render json: {success: false, redirect: true, message: "Maximum mumber of submissions reached for this task."}
      end
    end

    @task_submission.submission_type = @task.submission_type

    @task_submission.status = :pending

    @task_submission.meta = params[:meta]

    file_ids = @task_submission.uploaded_files

    if params[:files].present?
      params[:files].each do |file|
        if file.present?
          file_id = upload_file_to_telegram(file)
          file_ids << file_id if file_id
        end
      end
    end

    if @task_submission.update(description: params[:description],uploaded_files: file_ids)
      render json: {success: true, message: "Uploaded Successfully"}
    else
      render json: {success: false, message: "Something Went Wrong: #{@task_submission.errors.full_messages.join("/n")}"}
    end
  end

  def export_csv
    @task_submissions = TgTaskSubmission.includes(:tg_task,:tg_user)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ['Submission Id', 'Task ID', 'Task Name', 'User Name', 'Text Proof','Submitted At', 'Image/Video Prrof']

      @task_submissions.each do |tg_submission|
        tg_user = tg_submission.tg_user
        tg_task = tg_submission.tg_task
        csv << [tg_submission.id, tg_task.id,tg_task.name, tg_user.name, tg_submission.description,tg_submission.updated_at,tg_submission.submitted_urls(@base_url)]
      end
    end

    respond_to do |format|
      format.csv { send_data csv_data, filename: "tasks-#{Date.today}.csv" }
    end
  end

  def download_file
    file_id = params[:file_id]
  
    file_path = get_file_path_from_telegram(file_id)
  
    if file_path
      file_url = "https://api.telegram.org/file/bot#{@token_key}/#{file_path}"

      redirect_to file_url, allow_other_host: true
    else
      render plain: "File not found", status: :not_found
    end
  end
  

  def toogle_submission
    submission_code = params[:submission_code]
    toogle_type = params[:toogle_type]

    @submission = TgTaskSubmission.find_by(code: submission_code)

    return render json: {status: false, message: "Invalid Submission Id"} unless @submission.present?

    @task = @submission.tg_task

    if toogle_type == "rating"
      final_status = @submission.approved? ? "pending" : "approved" 
      if @submission.update(status: final_status)
        total_amount = @submission.tg_user.tg_task_submissions.approved.pluck(:earning).compact.sum
        @submission.tg_user.update_columns(total_earning: total_amount)
        return render json: {status: true, message: "Updated Successfully"}
      else
        return render json: {status: false, message: "Something Went Wrong"}
      end
    elsif toogle_type == "payment"
      final_paid = !@submission.is_paid
      amount =  final_paid ? @task.cost : nil
      if @submission.update(is_paid: final_paid,earning: amount)
        total_amount = @submission.tg_user.tg_task_submissions.approved.pluck(:earning).compact.sum
        @submission.tg_user.update_columns(total_earning: total_amount)
        return render json: {status: true, message: "Updated Successfully"}
      else
        return render json: {status: false, message: "Something Went Wrong"}
      end
    else
      render json: {status: false, message: "Invalid Action"}
    end
  end

  def bulk_change_status
    submission_ids = params[:submission_ids]
    new_status = params[:new_status]
  
    submissions = TgTaskSubmission.where(id: submission_ids)
  
    if submissions.empty?
      return render json: { status: false, message: "No valid submissions found." }
    end
    
    ids = []
    submissions.each do |submission|
      if submission.update(status: new_status)
        ids << submission.tg_user_id
      end
    end

    TgTaskSubmission.where(tg_user_id: ids,is_paid: true).group(:tg_user).sum(:earning).each do |user_id,amount|
      TgUser.where(id: user_id).update(total_earning: amount)
    end
    
  
    render json: { status: true, message: "Bulk status change completed successfully." }
  end
  
  def bulk_toggle_payment
    submission_ids = params[:submission_ids]
  
    submissions = TgTaskSubmission.where(id: submission_ids)
  
    if submissions.empty?
      return render json: { status: false, message: "No valid submissions found." }
    end
    
    ids = []

    submissions.each do |submission|
      if submission.update(is_paid: !submission.is_paid)
        ids << submission.tg_user_id
      end
    end

    TgTaskSubmission.where(tg_user_id: ids,is_paid: true).group(:tg_user).sum(:earning).each do |user_id,amount|
      TgUser.where(id: user_id).update(total_earning: amount)
    end
  
    render json: { status: true, message: "Bulk payment toggle completed successfully." }
  end

  def task_details
    @task_details = TgTaskDetail.where(tg_task_id: params[:id]).order(created_at: :desc)
  end

  def update_task_details
    task = TgTask.find_by(id: params[:id])
    deletable_ids = params[:deletable_ids]
    (params[:tg_task_details] || []).each do |task_detail_params|
      if task_detail_params[:id].present?
        task_detail = TgTaskDetail.find(task_detail_params[:id])
        if task_detail.update(details:task_detail_params[:details] )
        else
        end
      else
        TgTaskDetail.create(tg_task_id: task.id,details:task_detail_params[:details])
      end
    end

    TgTaskDetail.where(id: deletable_ids).delete_all
  
    render json: { status: 'success', message: 'Task details updated successfully.' }
  rescue => e
    render json: { status: 'error', message: e.message }, status: :unprocessable_entity
  end

  def add_remarks
    @tg_user = TgUser.find(params[:id])
    if @tg_user.update(remarks: params[:remarks])
      render json: { success: true, message: "Remarks updated successfully!" }
    else
      render json: { success: false, message: @tg_user.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end
  

  
  private

  def set_task
    @task = TgTask.find_by(id: params[:id])
  end

  def task_params
    params.require(:tg_task).permit(:cost, :name, :description, :status, :submission_type, :start_time, :end_time, :maximum_per_user,:minimum_gap_in_hours,:is_private, custom_fields: [])
  end

  def get_file_path_from_telegram(file_id)
    begin
      uri = URI("https://api.telegram.org/bot#{@token_key}/getFile?file_id=#{file_id}")
      
      response = Net::HTTP.get(uri)
      
      file_info = JSON.parse(response)
      
      if file_info['ok']
        file_info['result']['file_path']
      else
        nil
      end
    rescue StandardError => e
      logger.error "Error fetching file path: #{e.message}"
      nil
    end
  end

  def verify_access
    redirect_to "/users/sign_in" unless current_user.present?
  end
end
