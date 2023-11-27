class AddIndexToStocksOnDayAndTicker < ActiveRecord::Migration[7.0]
  def change
    add_index :stocks, [:day, :ticker]
  end
end
