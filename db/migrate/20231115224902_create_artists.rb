class CreateArtists < ActiveRecord::Migration[7.1]
  def change
    create_table :artists do |t|
      t.string :name
      t.string :image_url
      t.string :spotify_url
      t.text :genres
      t.integer :followers_total

      t.timestamps
    end
  end
end
