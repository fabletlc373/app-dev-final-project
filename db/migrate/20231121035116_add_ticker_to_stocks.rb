class AddTickerToStocks < ActiveRecord::Migration[7.0]
  def change
    add_column :stocks, :ticker, :string
  end
end
