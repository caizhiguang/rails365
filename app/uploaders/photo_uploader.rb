# encoding: utf-8

class PhotoUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  if Rails.env.test?
    storage :file
  else
    storage :aliyun
  end
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :preview do
    process resize_to_limit: [750, nil]
  end

  version :group do
    process resize_to_limit: [120, 120]
  end

  version :book do
    process resize_to_limit: [87, 116]
  end

  process :make_watermark => "https://rails365.oss-cn-shenzhen.aliyuncs.com/watermark_logo.png"
  def make_watermark(watermark)
    manipulate! do |img|
      img = img.composite(MiniMagick::Image.open(watermark, "jpg")) do |c|
        c.gravity "SouthEast"
      end
      img = yield(img) if block_given?
      img
    end
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  def filename
    if super.present?
      # current_path 是 Carrierwave 上传过程临时创建的一个文件，有时间标记，所以它将是唯一的
      @name ||= Digest::MD5.hexdigest(original_filename)
      "#{Time.zone.now.year}/#{@name}.#{file.extension.downcase}"
    end
  end
end
