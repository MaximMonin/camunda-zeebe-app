CarrierWave.configure do |config|
  config.permissions = 0666
  config.directory_permissions = 0777
  config.storage = :file
  # This avoids uploaded files from saving to public/ and so
  # they will not be available for public (non-authenticated) downloading
  config.root = Rails.root.to_s + '/storage'
end

module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end
