class CreateVacancies < ActiveRecord::Migration[8.0]
  def change
    create_table :vacancies do |t|
      t.string :title
      t.text :description
      t.string :salary
      t.string :location
      t.string :employment_type
      t.references :company, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
