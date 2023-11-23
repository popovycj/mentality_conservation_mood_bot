class Track < ApplicationRecord
  belongs_to :album

  serialize :lyrics_vector, Array, coder: YAML

  def self.ransackable_attributes(auth_object = nil)
    ["album_id", "artists", "created_at", "duration_ms", "id", "id_value", "lyrics", "name", "preview_url", "spotify_url", "updated_at"]
  end
end
