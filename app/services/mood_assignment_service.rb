class MoodAssignmentService
  attr_reader :answers

  MOOD_CATEGORIES = [:joyful, :sad, :angry, :fearful, :love, :nostalgic, :inspirational, :reflective].freeze

  def initialize(answers)
    @answers = answers
    @scores = Hash.new(0)
  end

  def calculate_scores
    calculate_initial_scores
    apply_mood_interactions
    normalize_scores
    @scores
  end

  private

  def calculate_initial_scores
    answers.each_with_index do |answer, index|
      category = MOOD_CATEGORIES[index / 2]
      @scores[category] += answer
    end
  end

  def apply_mood_interactions
    adjust_for_joyful_sad
    adjust_for_angry
    adjust_for_fearful
    adjust_for_love
    adjust_for_nostalgic
    adjust_for_inspirational
    adjust_for_reflective
  end

  def adjust_for_joyful_sad
    if average_score(:joyful) > 3
      @scores[:sad] *= 0.8
    end

    if average_score(:sad) > 3
      @scores[:joyful] *= 0.8
    end
  end

  def adjust_for_angry
    if average_score(:angry) > 3
      @scores[:fearful] *= 0.9
      @scores[:love] *= 0.9
    end
  end

  def adjust_for_fearful
    if average_score(:fearful) > 3
      @scores[:inspirational] *= 0.8
    end
  end

  def adjust_for_love
    if average_score(:love) > 3
      @scores[:nostalgic] *= 1.1
      @scores[:angry] *= 0.9
    end
  end

  def adjust_for_nostalgic
    if average_score(:nostalgic) > 3
      @scores[:reflective] *= 1.1
      @scores[:nostalgic] *= 0.85
    end
  end

  def adjust_for_inspirational
    if average_score(:inspirational) > 3
      @scores[:joyful] *= 0.9
      @scores[:nostalgic] *= 1.1
    end
  end

  def adjust_for_reflective
    if average_score(:reflective) > 3
      @scores[:joyful] *= 0.9
      @scores[:sad] *= 0.9
    end
  end

  def normalize_scores
    @scores.each do |category, score|
      @scores[category] = [[score, 0].max, 10].min.round
    end
  end

  def average_score(category)
    @scores[category] / 2.0
  end
end
