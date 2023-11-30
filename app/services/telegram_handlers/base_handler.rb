module TelegramHandlers
  class BaseHandler
    attr_reader :user_id, :bot

    def initialize(bot, user_id, questions, answers, state_expiration = 1.hour, state_erastion = true)
      @bot = bot
      @user_id = user_id
      @questions = questions
      @answers = answers
      @state = retrieve_or_initialize_state
      @state_expiration = state_expiration
      @state_erastion = state_erastion
    end

    def handle_response(message = nil)
      return ask_question if is_first_question? || message.nil?

      answer = message.text
      if valid_answer?(answer)
        process_answer(answer)
        ask_question
      else
        @bot.api.send_message(chat_id: @user_id, text: "Please select a valid answer.", reply_markup: reply_keyboard)
      end
    end

    protected

    def is_first_question?
      @state['question_index'] == 0
    end

    def process_answer(answer)
      @state['answers'] << @answers[answer]
      update_state
    end

    def ask_question
      if @state['question_index'] < @questions.length
        question = @questions[@state['question_index']]
        @bot.api.send_message(chat_id: @user_id, text: question, reply_markup: reply_keyboard)

        @state['question_index'] += 1
        update_state
      else
        complete_assessment
      end
    end

    def complete_assessment
      answers = @state['answers']
      clear_state if @state_erastion

      user_state = UserState.new(user_id)
      next_handler = user_state.next_handler(bot)

      next_handler.handle_response if next_handler

      @bot.api.send_message(chat_id: @user_id, text: "Answers: #{answers.join(', ')}\nHandler: #{self.class.name}")
    end

    def valid_answer?(answer)
      @answers.keys.include?(answer)
    end

    def reply_keyboard
      keyboard_buttons = @answers.keys.map { |answer| Telegram::Bot::Types::KeyboardButton.new(text: answer) }
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: keyboard_buttons.each_slice(2).to_a,
        resize_keyboard: true,
        one_time_keyboard: true
      )
    end

    private

    def retrieve_or_initialize_state
      state_key = "#{@user_id}_#{self.class.name}_state"
      kredis_state = Kredis.json state_key, expires_in: @state_expiration
      kredis_state.value || { 'question_index' => 0, 'answers' => [] }
    end

    def update_state
      state_key = "#{@user_id}_#{self.class.name}_state"
      kredis_state = Kredis.json state_key, expires_in: @state_expiration
      kredis_state.value = @state
    end

    def clear_state
      state_key = "#{@user_id}_#{self.class.name}_state"
      kredis_state = Kredis.json state_key, expires_in: @state_expiration
      kredis_state.clear
    end
  end
end
