class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable

  validates :username, presence: true 
  has_many :chat_messages, dependent: :destroy, inverse_of: :user
  has_many :user_files, dependent: :destroy, inverse_of: :user
  has_many :socials, dependent: :destroy, inverse_of: :user
  has_one_attached :photo
  audited

  private

  before_update do |user|
    user.phone_verified_at = nil if user.phone_changed?
  end 
  after_destroy do |user|
    FileUtils.rm_rf(Rails.root.to_s + '/storage/cdn/user' + user.id.to_s)
  end 
end
