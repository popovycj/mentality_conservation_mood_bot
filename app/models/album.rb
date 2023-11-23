class Album < ApplicationRecord
  serialize :genres, Array, coder: YAML

  belongs_to :artist
  has_many :tracks, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    ["artist_id", "created_at", "genres", "id", "id_value", "image_url", "name", "release_date", "spotify_url", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["artist", "tracks"]
  end
end
