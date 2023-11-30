module TelegramHandlers
  class MoodAssessmentHandler < BaseHandler
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

    STATE_EXPIRATION = 1.hour

    def initialize(bot, user_id)
      super(bot, user_id, QUESTIONS, ANSWER_SCORES, STATE_EXPIRATION)
    end

    protected

    def process_answers(answers)
      scores = MoodAssignmentService.new(answers).calculate_scores
      @bot.api.send_message(chat_id: @user_id, text: "Answers: #{answers.join(', ')}\nProcessed answers: #{scores}")
    end

    puts "Registering #{self.name.demodulize}..."
    TelegramHandlers::HandlerFactory.register_handler(self.name.demodulize, self)
  end
end
