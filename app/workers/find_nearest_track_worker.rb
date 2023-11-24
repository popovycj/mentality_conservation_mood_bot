require 'telegram/bot'

class FindNearestTrackWorker
  include Sidekiq::Worker

  def perform(telegram_user_id)
    user = User.find_by(telegram_user_id: telegram_user_id)

    scores = user.previous_mood_scores
    nearest_track_id = find_nearest_track_id(scores, user.recommended_track_ids)

    nearest_track = Track.find(nearest_track_id)
    send_track_recommendation(telegram_user_id, nearest_track)

    user.recommended_track_ids << nearest_track_id
    user.save!
  end

  private

  def find_nearest_track_id(scores, excluded_track_ids)
    vectors = find_track_vectors(excluded_track_ids)
    classifier = Knn::Classifier.new(vectors, 1, Knn::SquaredEuclideanCalculator)
    classifier.classify([nil] + scores)
  end

  def find_track_vectors(excluded_track_ids)
    return @vectors if @vectors.present?

    @vectors = []
    Track.where.not(id: excluded_track_ids).find_each do |track|
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
