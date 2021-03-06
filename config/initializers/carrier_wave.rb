if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Configuration for Amazon S3
      :provider              => 'AWS',
      :aws_access_key_id     => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
    config.fog_directory     =  ENV['S3_BUCKET_NAME']
    config.fog_attributes = { 'Cache-Control'=>'max-age=315576000', 'Expires' => 1.week.from_now.httpdate }
    config.fog_public = false
    config.fog_authenticated_url_expiration = 3600 * 24 #24h
  end
end

if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end

  # # make sure uploader is auto-loaded
  # FileUploader

  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      def cache_dir
        "#{Rails.root}/spec/support/uploads/tmp"
      end

      def store_dir
        "#{Rails.root}/spec/support/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end
    end
  end

  CarrierWave.configure do |config|
    config.asset_host = ActionController::Base.asset_host
  end
end