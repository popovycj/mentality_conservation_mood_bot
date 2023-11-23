ActiveAdmin.register Track do
  index do
    selectable_column
    id_column
    column :name
    column :preview_url do |album|
      audio_tag(album.preview_url, controls: true)
    end
    column :spotify_url
    column :lyrics
    column :album
    actions
  end

  show do
    attributes_table do
      row :name
      row :preview_url do |album|
        audio_tag(album.preview_url, controls: true)
      end
      row :spotify_url
      row :lyrics
      row :album
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :preview_url
      f.input :spotify_url
      f.input :lyrics
      f.input :album
    end
    f.actions
  end
end
