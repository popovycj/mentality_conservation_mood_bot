SPOTIFY_ARTISTS = [
  "SadSvit",
  "Rohata Zhaba",
  "Braty Hadiukiny",
  "Zlyj Reper Zenyk",
  "Харцизи",
  "паліндром",
  "Schmalgauzen",
  "Тінь Сонця",
  "Tartak",
  "Boombox",
  "Сусіди Стерплять",
  "Yurcash",
  "Re-read",
  "Покруч",
  "Electrobirds",
  "Mad Heads",
  "Karna",
  "thekomakoma",
  "Перший сніг",
  "Okean Elzy",
  "The Hardkiss",
  "badactress",
  "KLEFT",
  "Лівінсон",
  "Antytila",
  "Epolets",
  "Vivienne Mort",
  "Odyn v Kanoe",
  "Мертвий півень",
  "Джозерс",
  "Dymna Sumish",
  "Kozak System",
  "Vopli Vidopliassova",
  "квіткіс",
  "хейтспіч",
  "The Unsleeping",
  "FliT",
  "Жадан і Собаки",
  "Zwyntar",
  "Лінія Маннергейма",
  "TNMK",
  "DZIDZIO",
  "Discollusion",
  "Detach",
  "dity inzeneriv",
  "KOSMOPOLIS",
  "O.Torvald",
  "Vremya i Steklo",
  "Mistmorn",
  "Valentin Strykalo",
  "Inshe",
  "Сметана band",
  "Скрябін",
  "СТРУКТУРА ЩАСТЯ",
  "Апатія",
  "Після дощу",
  "Марний",
  "Dissapeared completely",
  "Sad Novelist",
  "Турбо-Техно-Саунд",
  "краш тест",
  "Granat Garden",
  "The Pamphlets",
  "Burned Time Machine",
  "Ziferblat",
  "Ницо Потворно",
].freeze


SPOTIFY_ARTISTS.each do |artist_name|
  next if Artist.exists?(name: artist_name)

  artist_index = case artist_name
  when "FliT", "Inshe"
    1
  when "Karna", "Boombox"
    2
  else
    0
  end

  artist = RSpotify::Artist.search(artist_name)[artist_index]

  artist_record = Artist.find_or_create_by(
    name: artist.name,
    image_url: (artist.images.first["url"] unless artist.images.first.blank?),
    spotify_url: artist.external_urls["spotify"],
    genres: artist.genres,
    followers_total: artist.followers["total"]
  )

  artist.albums.each do |album|
    begin
      ActiveRecord::Base.transaction do
        album_record = artist_record.albums.find_or_create_by(
          name: album.name,
          release_date: album.release_date,
          image_url: (album.images.first["url"] unless album.images.first.blank?),
          spotify_url: album.external_urls["spotify"],
          genres: album.genres,
        )

        track_data = album.tracks.map do |track|
          {
            name: track.name,
            preview_url: track.preview_url,
            spotify_url: track.external_urls["spotify"],
            duration_ms: track.duration_ms,
            artists: track.artists.map(&:name),
            album_id: album_record.id,
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        raise "only #{track_data.count} track" if track_data.count < 3

        Track.insert_all!(track_data)
        puts "Created #{track_data.count} tracks for #{album.name} by #{artist.name}"
      end
    end
  rescue => e
    puts "Album failed for artist '#{artist_name}': #{e.message}"
    next
  end
end
