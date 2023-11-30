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

    def process_answers(answers)
      @bot.api.send_message(chat_id: @user_id, text: "Your preferred languages are #{answers.join(', ')}")
    end

    puts "Registering #{self.name.demodulize}..."
    TelegramHandlers::HandlerFactory.register_handler(self.name.demodulize, self)
  end
end
