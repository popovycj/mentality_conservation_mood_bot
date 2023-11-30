module TelegramHandlers
  class HandlerFactory
    @handlers = {}

    class << self
      def register_handler(handler_name, klass)
        @handlers[handler_name] = klass
      end

      def create(bot, user_id, handler_name)
        handler_class = @handlers[handler_name]
        raise "Handler not registered: #{handler_name}" unless handler_class

        handler_class.new(bot, user_id)
      end
    end
  end
end
