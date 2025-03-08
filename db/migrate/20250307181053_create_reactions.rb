class CreateReactions < ActiveRecord::Migration[8.0]
  def change
    create_table :reactions do |t|
      t.references :activity, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :emoji_type, null: false

      t.timestamps
    end

    # Ensure users can only have one reaction per activity
    add_index :reactions, [ :user_id, :activity_id ], unique: true
  end
end
