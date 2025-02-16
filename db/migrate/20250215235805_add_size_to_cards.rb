class AddSizeToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :size, :string, default: "square"
  end
end
