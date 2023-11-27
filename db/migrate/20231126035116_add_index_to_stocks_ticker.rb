class AddIndexToStocksTicker < ActiveRecord::Migration[7.0]
  def change
    add_index :stocks, :ticker, unique: true
  end
end
