module TelegramHandlers
  class PreferredReleaseTimeRangeHandler < BaseHandler
    QUESTIONS = [
      "What release time range do you prefer?"
    ].freeze

    ANSWER_SCORES = {
      'To 2010' => (1900..2010),
      'From 2010 to present' => (2010..Time.now.year),
      'From the beginning of the war' => (2022..Time.now.year)
    }.freeze

    STATE_EXPIRATION = 24.hours

    def initialize(bot, user_id)
      super(bot, user_id, QUESTIONS, ANSWER_SCORES, STATE_EXPIRATION)
    end
  end

  puts "Registering PreferredReleaseTimeRangeHandler..."
  TelegramHandlers::HandlerFactory.register_handler('PreferredReleaseTimeRangeHandler', PreferredReleaseTimeRangeHandler)
end
