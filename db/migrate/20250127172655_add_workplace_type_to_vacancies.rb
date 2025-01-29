class AddWorkplaceTypeToVacancies < ActiveRecord::Migration[8.0]
  def change
    add_column :vacancies, :workplace_type, :string
  end
end
