class RemoveIndexFromStocksTicker < ActiveRecord::Migration[7.0]
  def change
    remove_index :stocks, :ticker
  end
end
