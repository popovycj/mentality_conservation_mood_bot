module TelegramHandlers
  class PreferredLanguageHandler < BaseHandler
    QUESTIONS = [
      "What languages do you prefer?"
    ].freeze

    ANSWER_SCORES = {
      'All' => [:ukrainian, :russian, :english],
      'Not russian' => [:ukrainian, :english],
      'Only Ukrainian' => [:ukrainian]
    }.freeze

    STATE_EXPIRATION = 24.hours

    def initialize(bot, user_id)
      super(bot, user_id, QUESTIONS, ANSWER_SCORES, STATE_EXPIRATION)
    end
  end

  puts "Registering PreferredLanguageHandler..."
  TelegramHandlers::HandlerFactory.register_handler('PreferredLanguageHandler', PreferredLanguageHandler)
end
