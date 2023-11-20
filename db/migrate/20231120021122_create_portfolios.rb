class CreatePortfolios < ActiveRecord::Migration[7.0]
  def change
    create_table :portfolios do |t|
      t.date :day
      t.integer :stock_id
      t.decimal :weight
      t.decimal :dollarpos
      t.decimal :portfoliovalue
      t.integer :user_id

      t.timestamps
    end
  end
end
