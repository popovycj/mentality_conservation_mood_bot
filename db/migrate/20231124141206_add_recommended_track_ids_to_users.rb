class AddRecommendedTrackIdsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :recommended_track_ids, :text
  end
end
