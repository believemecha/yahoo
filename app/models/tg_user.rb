class TgUser < ApplicationRecord

  before_create :generate_code_number

  private

  def generate_code_number
    return if code.present?
    loop do
      @code = Time.now.to_i.to_s + SecureRandom.hex(64 / 8).upcase
      break @code unless TgUser.exists?(code: @code)
    end
    self.code = @code
  end
end