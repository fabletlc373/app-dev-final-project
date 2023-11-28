class RenameAndChangeColumnType < ActiveRecord::Migration[7.0]
  def change
    rename_column :portfolios, :stock_id, :ticker
    change_column :portfolios, :ticker, :string
  end
end
