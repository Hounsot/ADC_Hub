class MakeCompanyIdNullableInVacancies < ActiveRecord::Migration[7.0]
  def up
    # 1. If there's a foreign key referencing :companies, you may need to remove and re-add it:
    remove_foreign_key :vacancies, :companies

    # 2. Change the column to allow NULL values:
    change_column_null :vacancies, :company_id, true

    # 3. Re-add the foreign key without enforcing NOT NULL:
    add_foreign_key :vacancies, :companies
  end

  def down
    # Reverse the changes if needed
    remove_foreign_key :vacancies, :companies
    change_column_null :vacancies, :company_id, false
    add_foreign_key :vacancies, :companies
  end
end
