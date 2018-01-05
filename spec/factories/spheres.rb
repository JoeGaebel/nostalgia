FactoryBot.define do
  factory :sphere do
    memory
    guid { SecureRandom.hex }
    caption { Faker::Space.planet }
    panorama { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'rails.png'), 'image/jpeg') }
  end
end
