require 'telegram/bot'

class FindNearestTrackWorker
  include Sidekiq::Worker

  def perform(telegram_user_id)
    scores = User.find_by(telegram_user_id: telegram_user_id).previous_mood_scores

    vectors = Track.all.map { |t| [t.id] + t.lyrics_vector }
    classifier = Knn::Classifier.new(vectors, 3, Knn::SquaredEuclideanCalculator)

    nearest_track_id = classifier.classify([nil] + scores)
    nearest_track = Track.find(nearest_track_id)

    bot = Telegram::Bot::Client.new(Rails.application.credentials.telegram[:token])
    bot.api.send_message(chat_id: telegram_user_id, text: "The nearest track to your mood is: #{nearest_track.name}\nLink: #{nearest_track.spotify_url}")
  end
end
