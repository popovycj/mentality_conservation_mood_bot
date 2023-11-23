namespace :telegram do
  desc "Run the Telegram bot"
  task bot: :environment do
    require 'telegram/bot'

    QUESTIONS = [
      "How often do you feel a burst of energy and happiness for no specific reason?",
      "Do you frequently find yourself enjoying small, everyday moments?",
      "Do you often feel overwhelmed by a sense of sadness or hopelessness?",
      "Is it common for you to feel a sense of loss or emptiness?",
      "How frequently do you find yourself feeling unexplainably angry or irritated?",
      "Do you often struggle to control feelings of anger in daily situations?",
      "Do you regularly experience fear or anxiety about unforeseen events?",
      "How often do you find yourself worrying excessively about the future?",
      "How frequently do you feel deep affection and connection with those around you?",
      "Do you often find yourself expressing love and compassion towards others?",
      "Is it common for you to reminisce about the past with longing or wistfulness?",
      "Do you frequently find comfort in memories and past experiences?",
      "How often do you feel a strong drive to pursue new ideas or goals?",
      "Do you regularly find inspiration in your daily life that motivates you?",
      "Do you often spend time reflecting on your personal growth and experiences?",
      "How frequently do you find yourself pondering over life's deeper meanings?"
    ]

    ANSWER_SCORES = {
      'Always' => 5,
      'Often' => 4,
      'Sometimes' => 3,
      'Rarely' => 2,
      'Never' => 1
    }

    KEYBOARD_BUTTONS = ANSWER_SCORES.keys.map do |answer|
      Telegram::Bot::Types::KeyboardButton.new(text: answer)
    end

    REPLY_KEYBOARD = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: KEYBOARD_BUTTONS.each_slice(2).to_a,
      resize_keyboard: true,
      one_time_keyboard: true
    )

    Telegram::Bot::Client.run(Rails.application.credentials.telegram[:token]) do |bot|
      bot.listen do |message|
        kredis_state = Kredis.json "#{message.from.id}_state", expires_in: 1.hour
        state = kredis_state.value || {}

        case message.text
        when '/start'
          bot.api.send_message(chat_id: message.chat.id, text: "Welcome! Let's start the mood assessment.")
          state = { 'question_index' => 0, 'answers' => [] }
          kredis_state.value = state
          bot.api.send_message(chat_id: message.chat.id, text: QUESTIONS.first, reply_markup: REPLY_KEYBOARD)
        else
          if state['question_index']
            answer = ANSWER_SCORES[message.text]

            if answer
              state['answers'] << answer
              next_question_index = state['question_index'] + 1

              if next_question_index < QUESTIONS.length
                state['question_index'] = next_question_index
                kredis_state.value = state
                bot.api.send_message(chat_id: message.chat.id, text: QUESTIONS[next_question_index], reply_markup: REPLY_KEYBOARD)
              else
                scores = MoodAssignmentService.new(state['answers']).calculate_scores.values
                user = User.find_or_create_by(telegram_user_id: message.from.id).update(previous_mood_scores: scores)
                bot.api.send_message(chat_id: message.chat.id, text: "Thank you for completing the assessment. Your results have been saved.")
                FindNearestTrackWorker.perform_async(user.telegram_user_id)
                kredis_state.clear
              end
            else
              bot.api.send_message(chat_id: message.chat.id, text: "Please select an answer from the options.", reply_markup: REPLY_KEYBOARD)
            end
          end
        end
      end
    end
  end
end
