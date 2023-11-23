class Artist < ApplicationRecord
  serialize :genres, Array, coder: YAML

  has_many :albums, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "followers_total", "genres", "id", "id_value", "image_url", "name", "spotify_url", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["albums"]
  end
end
