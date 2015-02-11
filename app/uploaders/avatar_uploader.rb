class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

  storage :ftp

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    ActionController::Base.helpers.asset_path([version_name, 'default.jpg'].compact.join('_'))
    # [version_name, 'default.png'].compact.join('_')
    # "/images/" + [version_name, "default.png"].compact.join('_')
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  process resize_to_limit: [100, 100]

  version :icon do
    process resize_to_limit: [40, 40]
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
