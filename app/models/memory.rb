class Memory < ApplicationRecord
  belongs_to :user
  has_many :spheres

  has_one :sound_context, as: :context
  has_one :default_sound, through: :sound_context, source: :sound

  def to_builder

    Jbuilder.new do |json|
      json.(self, :id, :name)
      json.spheres spheres.collect { |sphere| sphere.to_builder.attributes! }
      if default_sound.present?
        json.defaultSound default_sound.to_builder
      end
    end
  end
end
