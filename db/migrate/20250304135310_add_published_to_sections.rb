class AddPublishedToSections < ActiveRecord::Migration[8.0]
  def change
    add_column :sections, :published, :boolean
  end
end
