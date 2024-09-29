class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  before_create :set_default_role


  def self.ransackable_attributes(auth_object = nil)
    ["country_code", "created_at", "email", "first_name", "id", "last_name", "phone", "remember_created_at", "reset_password_sent_at", "role", "updated_at"]
  end


  VALID_TYPES = %w[Admin User Partner].freeze

  enum roles:{
    admin: "Admin",
    user: "User",
    partner: "Partner"
  }

  VALID_TYPES.each do |user_role|
    # def admin?
    # def user?
    # def partner? 
    define_method "#{user_role.underscore}?" do
      role == user_role
    end
  end

  def name
    if first_name || last_name
      return "#{first_name} #{last_name}"
    end
    email
  end

  private
  
  def set_default_role
    self.role ||= 'User'
  end

  
end
