# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update,:create_or_edit,:new,:add_files]

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
  end

  def upload_file_to_telegram(file,chat_id = nil)
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

  def complete_task
    @task = TgTask.find_by(code: params[:task_code])
    @user = TgUser.find_by(code: params[:user_code])

    return render json: {success: false, message: "Invalid Request"} unless @task.present? && @user.present?

    @task_submission = TgTaskSubmission.find_by(tg_user_id: @user.try(:id), tg_task_id: @task.try(:id))

    @is_new_submission = @task_submission.nil?
  end

  def update_complete_task
    @task = TgTask.find_by(code: params[:task_code])
    @user = TgUser.find_by(code: params[:user_code])

    return render json: {success: false, message: "Invalid Request"} unless @task.present? && @user.present?

    
    @task_submission = TgTaskSubmission.find_or_initialize_by(tg_user_id: @user.try(:id), tg_task_id: @task.try(:id))

    @task_submission.submission_type = @task.submission_type

    @task_submission.status = :pending

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
      render json: {success: false, message: "Uploaded Successfully"}
    else
      render json: {success: false, message: "Something Went Wrong: #{@task_submission.errors.full_messages.join("/n")}"}
    end
  end

  private

  def set_task
    @task = TgTask.find_by(id: params[:id])
  end

  def task_params
    params.require(:tg_task).permit(:cost, :name, :description, :status, :submission_type, :start_time, :end_time, links: [])
  end
end
