namespace :spotify do
  desc "Update tracks without lyrics"
  task update_lyrics: :environment do
    require 'net/http'
    require 'uri'
    require 'json'

    Track.where(lyrics: nil).find_each do |track|
      next if track.spotify_url.blank?

      uri = URI("https://spotify-lyric-api-984e7b4face0.herokuapp.com/?url=#{track.spotify_url}")
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)

      next if result['error']

      lyrics = result['lines'].map { |line| line['words'] }.join("\n")
      track.update(lyrics: lyrics)

      puts "Updated lyrics for track: #{track.id}"
    rescue => e
      puts "Failed to update track #{track.spotify_url}: #{e.message}"
    end
  end
end
