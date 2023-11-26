# == Schema Information
#
# Table name: portfolios
#
#  id             :integer          not null, primary key
#  day            :date
#  dollarpos      :decimal(, )
#  portfoliovalue :decimal(, )
#  weight         :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  stock_id       :integer
#  user_id        :integer
#
class Portfolio < ApplicationRecord
  validates(:stock_id, {:uniqueness => {:scope => [:user_id, :day]}})
  validates(:day, {:uniqueness => {:scope => [:id]}})
  validates(:dollarpos, {:presence => true})
  validates(:weight, {:presence => true})
  validates(:portfoliovalue, {:presence => true})

  
  has_many(:stocks, class_name='Stock', foreign_key='stock_id')
  belongs_to(:user, class_name='User', foreign_key='user_id')
end
