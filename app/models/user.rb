class User < ApplicationRecord
  serialize :previous_mood_scores, type: Array, coder: YAML
end
