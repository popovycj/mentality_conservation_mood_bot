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

    def process_answers(answers)
      @bot.api.send_message(chat_id: @user_id, text: "Your preferred release time range is #{answers.join(', ')}")
    end

    puts "Registering #{self.name.demodulize}..."
    TelegramHandlers::HandlerFactory.register_handler(self.name.demodulize, self)
  end
end
