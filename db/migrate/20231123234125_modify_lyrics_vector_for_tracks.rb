class ModifyLyricsVectorForTracks < ActiveRecord::Migration[7.1]
  def change
    remove_column :albums, :lyrics_vector, :text
    add_column :tracks, :lyrics_vector, :text
  end
end
