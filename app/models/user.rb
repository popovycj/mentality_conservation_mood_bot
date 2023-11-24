class User < ApplicationRecord
  serialize :previous_mood_scores, type: Array, coder: YAML
  serialize :recommended_track_ids, type: Array, coder: YAML
end
