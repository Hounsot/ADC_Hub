class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.string :action
      t.references :actor, polymorphic: true, null: false
      t.references :subject, polymorphic: true, null: true

      t.timestamps
    end
  end
end
