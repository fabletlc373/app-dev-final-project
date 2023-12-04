class Portfolio_Init_Value < ApplicationRecord
  # weights cannot be > 1
  validates(:portfoliovalue, {:presence => true})
end
