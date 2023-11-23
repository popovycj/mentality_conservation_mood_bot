class AddLyricsVectorToAlbums < ActiveRecord::Migration[7.1]
  def change
    add_column :albums, :lyrics_vector, :text
  end
end
