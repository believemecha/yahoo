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

  # Add a method to check if submission has files
  def has_files?
    uploaded_files.any?
  end
end
