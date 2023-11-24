require 'telegram/bot'

class FindNearestTrackWorker
  include Sidekiq::Worker

  def perform(telegram_user_id)
    user = User.find_by(telegram_user_id: telegram_user_id)

    scores = user.previous_mood_scores
    nearest_track_id = find_nearest_track_id(scores)

    nearest_track = Track.find(nearest_track_id)
    send_track_recommendation(telegram_user_id, nearest_track)
  end

  private

  def find_nearest_track_id(scores)
    classifier = Knn::Classifier.new(track_vectors, 3, Knn::SquaredEuclideanCalculator)
    classifier.classify([nil] + scores)
  end

  def track_vectors
    return @vectors if @vectors.present?

    @vectors = []
    Track.find_each do |track|
      @vectors << [track.id] + track.lyrics_vector
    end
    @vectors
  end

  def send_track_recommendation(telegram_user_id, track)
    bot = Telegram::Bot::Client.new(Rails.application.credentials.telegram[:token])
    message = "The nearest track to your mood is: #{track.name}\nLink: #{track.spotify_url}"
    bot.api.send_message(chat_id: telegram_user_id, text: message)
  end
end
