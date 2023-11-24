module TelegramBot
  class MoodAssessmentBot
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
    ].freeze

    ANSWER_SCORES = {
      'Always' => 5,
      'Often' => 4,
      'Sometimes' => 3,
      'Rarely' => 2,
      'Never' => 1
    }.freeze

    def initialize(bot)
      @bot = bot
    end

    def handle_message(message)
      user_id = message.from.id
      state = retrieve_or_initialize_state(user_id)

      case message.text
      when '/start'
        handle_start(message, state)
      when '/new'
        FindNearestTrackWorker.perform_async(user_id)
      else
        handle_response(message, state)
      end
    end

    private

    def handle_start(message, state)
      state.update('question_index' => 0, 'answers' => [])
      update_state(message.from.id, state)
      @bot.api.send_message(chat_id: message.chat.id, text: QUESTIONS.first, reply_markup: reply_keyboard)
    end

    def handle_response(message, state)
      if state['question_index']
        answer = ANSWER_SCORES[message.text]
        if answer
          process_answer(message, answer, state)
        else
          @bot.api.send_message(chat_id: message.chat.id, text: "Please select an answer from the options.", reply_markup: reply_keyboard)
        end
      end
    end

    def process_answer(message, answer, state)
      state['answers'] << answer
      next_question_index = state['question_index'] + 1

      if next_question_index < QUESTIONS.length
        state['question_index'] = next_question_index
        update_state(message.from.id, state)
        @bot.api.send_message(chat_id: message.chat.id, text: QUESTIONS[next_question_index], reply_markup: reply_keyboard)
      else
        complete_assessment(message, state)
      end
    end

    def complete_assessment(message, state)
      user_id = message.from.id
      scores = MoodAssignmentService.new(state['answers']).calculate_scores.values
      User.find_or_create_by(telegram_user_id: user_id).update(previous_mood_scores: scores)

      clear_state(user_id)
      @bot.api.send_message(chat_id: message.chat.id, text: "Thank you for completing the assessment. Your results have been saved.")
      FindNearestTrackWorker.perform_async(user_id)
    end

    def keyboard_buttons
      ANSWER_SCORES.keys.map do |answer|
        Telegram::Bot::Types::KeyboardButton.new(text: answer)
      end
    end

    def reply_keyboard
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: keyboard_buttons.each_slice(2).to_a,
        resize_keyboard: true,
        one_time_keyboard: true
      )
    end

    def retrieve_or_initialize_state(user_id)
      kredis_state = Kredis.json "#{user_id}_state", expires_in: 1.hour
      kredis_state.value || {}
    end

    def update_state(user_id, state)
      kredis_state = Kredis.json "#{user_id}_state", expires_in: 1.hour
      kredis_state.value = state
    end

    def clear_state(user_id)
      kredis_state = Kredis.json "#{user_id}_state", expires_in: 1.hour
      kredis_state.clear
    end
  end
end


namespace :telegram do
  desc "Run the Telegram bot"
  task bot: :environment do
    require 'telegram/bot'

    Telegram::Bot::Client.run(Rails.application.credentials.telegram[:token]) do |bot|
      mood_bot = TelegramBot::MoodAssessmentBot.new(bot)
      bot.listen do |message|
        mood_bot.handle_message(message)
      end
    end
  end
end
