class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :telegram_user_id
      t.text :previous_mood_scores

      t.timestamps
    end
  end
end
