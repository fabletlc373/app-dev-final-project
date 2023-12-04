class RemoveWeightFromPortfolio < ActiveRecord::Migration[7.0]
  def change
    remove_column :portfolios, :weight
    remove_column :portfolios, :ticker
    remove_column :portfolios, :dollarpos
  end
end
