class CreateTracks < ActiveRecord::Migration[7.1]
  def change
    create_table :tracks do |t|
      t.string :name
      t.string :preview_url
      t.string :spotify_url
      t.integer :duration_ms
      t.text :artists
      t.text :lyrics
      t.references :album, null: false, foreign_key: true

      t.timestamps
    end
  end
end
