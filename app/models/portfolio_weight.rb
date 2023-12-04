class Portfolio_Weight < ApplicationRecord
  # weights cannot be > 1
  validates(:weight, {:presence => true})
  validates :weight, numericality: { less_than_or_equal_to: 1 }
  validates :weight, numericality: { greater_than_or_equal_to: 0 }
end
