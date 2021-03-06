class SphereUploader < BaseUploader
  include ::CarrierWave::Backgrounder::Delay
  MAX_WIDTH = 5000

  process resize_to_limit: [MAX_WIDTH, -1]
  process :optimize

  version :thumb do
    process resize_to_fill: [80, 80]
  end
end
