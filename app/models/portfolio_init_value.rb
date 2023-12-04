class PortfolioInitValue < ApplicationRecord
  self.table_name = "portfolio_init_values"
  # weights cannot be > 1
  validates(:portfoliovalue, {:presence => true})
end
