module TelegramHandlers
  class UserState
    def initialize(user_id)
      @user_id = user_id
      @kredis_key = "user_#{@user_id}_state"
      @state = Kredis.json @kredis_key, expires_in: 24.hours
      initialize_state
    end

    def current_handler
      state_value['handlers'].first
    end

    def next_handler(bot)
      advance_handler
      handler_class_name = current_handler
      return unless handler_class_name

      TelegramHandlers::HandlerFactory.create(bot, @user_id, handler_class_name)
    end

    def queue_handler(handler_name)
      update_state('handlers' => (state_value['handlers'] + [handler_name]).uniq)
    end

    def advance_handler
      handlers = state_value['handlers']
      handlers.shift
      update_state('handlers' => handlers)
    end

    def clear_state
      @state.clear
    end

    private

    def initialize_state
      @state.value ||= { 'handlers' => [] }
    end

    def state_value
      @state.value || { 'handlers' => [] }
    end

    def update_state(new_values)
      @state.value = state_value.merge(new_values)
    end
  end
end
