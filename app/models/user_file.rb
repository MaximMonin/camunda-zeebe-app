class UserFile < ApplicationRecord
  validates :file, presence: true 
  validates :filename, presence: true 
  validates :filetype, presence: true 
  validates :filesize, numericality: { greater_than: 0 }

  belongs_to :user, inverse_of: :user_files
  audited

  after_save do |user_files|
    user = User.find(user_files.user_id)
    user.files_updated_at = DateTime.now
    user.save
  end 
  after_destroy do |user_files|
    user = User.find(user_files.user_id)
    user.files_updated_at = DateTime.now
    user.save
  end 
end
