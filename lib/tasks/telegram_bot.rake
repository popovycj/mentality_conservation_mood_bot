namespace :telegram do
  desc "Run the Telegram bot"
  task bot: :environment do
    require 'telegram/bot'

    Dir[Rails.root.join('app', 'services', 'telegram_handlers', '*.rb')].each { |file| require file }


    Telegram::Bot::Client.run(Rails.application.credentials.telegram[:token]) do |bot|
      bot.listen do |message|
        user_id = message.from.id
        user_state = TelegramHandlers::UserState.new(user_id)

        case message.text
        when '/start'
          user_state.clear_state
          user_state.queue_handler('MoodAssessmentHandler')
          user_state.queue_handler('PreferredLanguageHandler')
          user_state.queue_handler('PreferredReleaseTimeRangeHandler')
        when '/new'
          user_state.clear_state
          user_state.queue_handler('PreferredLanguageHandler')
          user_state.queue_handler('PreferredReleaseTimeRangeHandler')
        end

        handler = user_state.current_handler ? TelegramHandlers::HandlerFactory.create(bot, user_id, user_state.current_handler) : nil

        if handler
          handler.handle_response(message)
        else
          bot.api.send_message(chat_id: user_id, text: "Type '/start' to begin.")
        end
      end
    end
  end
end
