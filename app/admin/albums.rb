ActiveAdmin.register Album do
  index do
    selectable_column
    id_column
    column :name
    column :release_date
    column :image_url do |album|
      image_tag(album.image_url, width: 50) if album.image_url.present?
    end
    column :spotify_url do |album|
      link_to album.spotify_url, album.spotify_url
    end
    column :genres
    column :artist
    column :lyrics_vector
    actions
  end

  show do
    attributes_table do
      row :name
      row :release_date
      row :image_url do |album|
        image_tag(album.image_url, width: 300) if album.image_url.present?
      end
      row :spotify_url do |album|
        link_to album.spotify_url, album.spotify_url
      end
      row :genres
      row :artist
      row :lyrics_vector
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :release_date
      f.input :image_url
      f.input :spotify_url
      f.input :genres
      f.input :artist
      f.input :lyrics_vector
    end
    f.actions
  end

  filter :name
  filter :release_date
  filter :genres
  filter :artist
end
