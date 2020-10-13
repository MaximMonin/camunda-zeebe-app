class UploadController < ApplicationController
  def new  
    user = current_user.id
    FileUtils.mkdir_p( Rails.root.to_s + '/storage/cache')
    FileUtils.mkdir_p( Rails.root.to_s + '/storage/cdn/user' + user.to_s)

    uploader = MyFilesUploader.new
    uploader.store!(params[:file])

    mime_type = uploader.content_type
    filesize = uploader.size
    originalname = uploader.get_originalname

    # Moving files to users dir, CarrierWave cant use current_user
    filenew = URI.decode_www_form_component(uploader.url)
    filepreview = URI.decode_www_form_component(uploader.preview.url) if mime_type.start_with? 'image'
    filenew = filenew[5, filenew.length]
    filepreview = filepreview[5, filepreview.length] if filepreview.present?
    FileUtils.mv(Rails.root.to_s + '/storage/cdn/' + filenew, Rails.root.to_s + '/storage/cdn/user' + user.to_s + '/')
    FileUtils.mv(Rails.root.to_s + '/storage/cdn/' + filepreview, Rails.root.to_s + '/storage/cdn/user' + user.to_s + '/') if filepreview.present?

    if params[:todo] == 'SaveMyFiles'
      if filepreview.present?
         UserFile.create user_id: user,
                            file: 'cdn/user' + user.to_s + '/' + filenew,
                        filename: originalname,
                        filetype: mime_type,
                        filesize: filesize,
                     filepreview: 'cdn/user' + user.to_s + '/' + filepreview
      else
         UserFile.create user_id: user,
                            file: 'cdn/user' + user.to_s + '/' + filenew,
                        filename: originalname,
                        filetype: mime_type,
                        filesize: filesize
      end
      VideoconvertJob.perform_later ('cdn/user' + user.to_s + '/' + filenew) if mime_type.start_with? 'video'
    end

    filepreview = filepreview || ''
    render json: {path: 'cdn/user' + user.to_s, name: filenew, mime_type: mime_type, filesize: filesize, originalname: originalname, preview: filepreview}
  end
  def delete
    filedel = Rails.root.to_s + '/storage/' + params[:file]
    File.delete(filedel) if File.exist?(filedel)
    UserFile.where(file: params[:file]).destroy_all
  end
end
