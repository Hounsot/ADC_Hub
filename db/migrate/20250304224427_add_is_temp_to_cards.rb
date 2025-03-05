class AddIsTempToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :is_temp, :boolean
  end
end
