class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.references :user, null: false, foreign_key: true
      t.string :card_type
      t.string :title
      t.text :content
      t.string :url
      t.integer :position

      t.timestamps
    end
  end
end
