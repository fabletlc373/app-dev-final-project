# == Schema Information
#
# Table name: portfolios
#
#  id             :integer          not null, primary key
#  day            :date
#  dollarpos      :decimal(, )
#  portfoliovalue :decimal(, )
#  ticker         :string
#  weight         :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#
class Portfolio < ApplicationRecord
  validates(:ticker, {:uniqueness => {:scope => [:user_id, :day]}})
  validates(:day, {:uniqueness => {:scope => [:id]}})
  validates(:dollarpos, {:presence => true})
  validates(:weight, {:presence => true})
  validates(:portfoliovalue, {:presence => true})

  
  #has_many(:stocks, class_name='Stock', foreign_key='ticker')
  #belongs_to(:user, class_name='User', foreign_key='user_id')
end
