class CreateAlbums < ActiveRecord::Migration[7.1]
  def change
    create_table :albums do |t|
      t.string :name
      t.date :release_date
      t.string :image_url
      t.string :spotify_url
      t.text :genres
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
