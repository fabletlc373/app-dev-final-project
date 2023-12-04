class CreatePortfolioInitValue < ActiveRecord::Migration[7.0]
  def change
    create_table :portfolio_init_values do |t|
      t.integer :user_id
      t.decimal :init_value
      t.timestamps
    end
  end
end
