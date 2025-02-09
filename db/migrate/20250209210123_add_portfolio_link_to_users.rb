class AddPortfolioLinkToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :portfolio_link, :string
  end
end
