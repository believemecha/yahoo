# app/models/tg_task.rb
class TgTask < ApplicationRecord

  has_many :tg_task_submissions
  
  # Enums for task status
  enum status: {
    active: 0,
    inactive: 1
  }

  # Enums for submission types
  enum submission_type: {
    text: 0,
    image: 1,
    video: 2
  }

  # Validations (add any necessary validations here)
  validates :name, presence: true
  validates :description, presence: true
  validates :cost, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true
  validates :submission_type, presence: true
  validates :start_time, :end_time, presence: true


  before_create :generate_code_number

  private

  def generate_code_number
    return if code.present?
    loop do
      @code = Time.now.to_i.to_s + SecureRandom.hex(64 / 8).upcase
      break @code unless TgTask.exists?(code: @code)
    end
    self.code = @code
  end
end
