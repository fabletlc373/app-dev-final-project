class CreateStocks < ActiveRecord::Migration[7.0]
  def change
    create_table :stocks do |t|
      t.date :day
      t.decimal :close
      t.decimal :open
      t.decimal :high
      t.decimal :low
      t.decimal :return

      t.timestamps
    end
  end
end
