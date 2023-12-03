class RenameportfolioToportfolios < ActiveRecord::Migration[7.0]
  def change
    rename_table :portfolio, :portfolios
  end
end
