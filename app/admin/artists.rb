ActiveAdmin.register Artist do
  index do
    selectable_column
    id_column
    column :name
    column :image_url do |artist|
      image_tag(artist.image_url, width: 50) if artist.image_url.present?
    end
    column :spotify_url
    column :genres
    column :followers_total
    actions
  end

  show do
    attributes_table do
      row :name
      row :image_url do |artist|
        image_tag(artist.image_url, width: 300) if artist.image_url.present?
      end
      row :spotify_url
      row :genres
      row :followers_total
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :image_url
      f.input :spotify_url
      f.input :genres
      f.input :followers_total
    end
    f.actions
  end
end
