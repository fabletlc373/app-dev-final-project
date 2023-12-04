class CreatePortfolioWeights < ActiveRecord::Migration[7.0]
  def change
    create_table :portfolio_weights do |t|
      t.integer :user_id
      t.string :ticker
      t.decimal :weight
      t.timestamps
    end
  end
end
