class MyFilesUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # we replicate this idea of generic types from CarrierWave::MimeTypes
  GENERIC_CONTENT_TYPES = %w[application/octet-stream binary/octet-stream]

  process :clear_generic_content_type

  storage :file
  permissions = 0666
  directory_permissions = 0777

  before :store, :remember_cache_id
  after :store, :delete_tmp_dir

  # store! nil's the cache_id after it finishes so we need to remember it for deletion
  def remember_cache_id(new_file)
    @cache_id_was = cache_id
  end

  def get_originalname
    original_filename
  end

  def clear_generic_content_type
    file.content_type = nil if GENERIC_CONTENT_TYPES.include?(file.try(:content_type))
  end
  
  def delete_tmp_dir(new_file)
    # make sure we don't delete other things accidentally by checking the name pattern
    if @cache_id_was.present? && @cache_id_was =~ /\A[\d]+\-[\d]+(\-[\d]{4})?\-[\d]{4}\z/
      FileUtils.rm_rf(File.join(root, cache_dir, @cache_id_was))
    end
  end

  def move_to_cache
    true
  end
  def move_to_store
    true
  end
  def store_dir
    "cdn"
  end
  def cache_dir
    'cache'
  end
  def filename
    @name = "#{SecureRandom.uuid}_#{original_filename}" if original_filename.present?
  end  

  version :preview, :if => :image? do
    process :resize_to_limit => [300, 300]
    process :quality => 80 
  end
  protected
  def image?(new_file)
    new_file.content_type.start_with? 'image'
  end
end
