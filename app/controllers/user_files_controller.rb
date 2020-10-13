class UserFilesController < ApplicationController
  before_action :authenticate_user!

  def show
    if params[:id] == 'docs' 
      doc
    end
    if params[:id] == 'videos' 
      video
    end
    if params[:id] == 'photos' 
      photo
    end
    if not (params[:id] == 'photos' || params[:id] == 'videos' || params[:id] == 'docs')
      render plain: 'error'
    end
  end

  def cachekey
    user = current_user
    filesupdated = user.files_updated_at
    filesupdated = DateTime.now if filesupdated.nil?
    'userfiles-' + user.id.to_s + '-' + filesupdated.utc.strftime("%Y%m%d%H%M%S%6N") + '-' + params[:page].to_s + "-" + params[:id].to_s 
  end                                                      

  def doc
    files = Rails.cache.read(cachekey)
    if files.nil?
      files = UserFile.where(user_id: current_user.id).where("NOT (filetype LIKE 'image%' or filetype IN ('video/mp4', 'video/ogg', 'video/webm'))").order(created_at: :desc).paginate(:per_page => 20, :page => params[:page])
      Rails.cache.write(cachekey, files)
    end
    render json: files
  end
  def video
    files = Rails.cache.read(cachekey)
    if files.nil?
      files = UserFile.where(user_id: current_user.id).where("filetype IN ('video/mp4', 'video/ogg', 'video/webm')").order(created_at: :desc).paginate(:per_page => 20, :page => params[:page])
      Rails.cache.write(cachekey, files)
    end
    render json: files
  end
  def photo
    files = Rails.cache.read(cachekey)
    if files.nil?
      files = UserFile.where(user_id: current_user.id).where("filetype LIKE 'image%'").order(created_at: :desc).paginate(:per_page => 20, :page => params[:page])
      Rails.cache.write(cachekey, files)
    end
    render json: files
  end
end

