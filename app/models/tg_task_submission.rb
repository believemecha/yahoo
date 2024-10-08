# app/models/tg_task_submission.rb
class TgTaskSubmission < ApplicationRecord
  belongs_to :tg_task
  belongs_to :tg_user

  # Enums for status and submission type
  enum status: { pending: 0, approved: 1, rejected: 2 }
  enum submission_type: { text: 0, image: 1, video: 2 }

  # Validations
  validates :description, presence: true
  validates :tg_task_id, presence: true
  validates :tg_user_id, presence: true

  before_create :generate_code_number

  after_commit :free_task_details

  # Add a method to check if submission has files
  def has_files?
    uploaded_files.any?
  end

  def submitted_urls(base_url)
    uploaded_files.map {|file_id| base_url + "/tasks/download_file?file_id=#{file_id}"}.join(" , ")
  end

  def urls(base_url)
    uploaded_files.map {|file_id| base_url + "/tasks/download_file?file_id=#{file_id}"}
  end


  private

  def generate_code_number
    return if code.present?
    loop do
      @code = Time.now.to_i.to_s + SecureRandom.hex(64 / 8).upcase
      break @code unless TgTaskSubmission.exists?(code: @code)
    end
    self.code = @code
  end

  def free_task_details
    if rejected?
      task_details = TgTaskDetail.where(tg_task_id: tg_task_id,tg_user_id: tg_user_id).update_all(tg_user_id: nil)
    end
  end

end
