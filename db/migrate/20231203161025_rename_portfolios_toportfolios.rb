class RenamePortfoliosToportfolios < ActiveRecord::Migration[7.0]
  def change
    rename_table :Portfolios, :portfolio
  end
end
