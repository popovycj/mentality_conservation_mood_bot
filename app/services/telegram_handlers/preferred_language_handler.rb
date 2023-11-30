module TelegramHandlers
  class PreferredLanguageHandler < BaseHandler
    QUESTIONS = I18n.t("telegram_handlers.#{self.name.demodulize.underscore}.questions").freeze
    ANSWER_SCORES = I18n.t("telegram_handlers.#{self.name.demodulize.underscore}.answer_scores").freeze

    STATE_EXPIRATION = 24.hours

    def initialize(bot, user_id)
      super(bot, user_id, QUESTIONS, ANSWER_SCORES.transform_keys(&:to_s), STATE_EXPIRATION)
    end

    def process_answers(answers)
      @bot.api.send_message(chat_id: @user_id, text: "Your preferred languages are #{answers.join(', ')}")
    end

    puts "Registering #{self.name.demodulize}..."
    TelegramHandlers::HandlerFactory.register_handler(self.name.demodulize, self)
  end
end
