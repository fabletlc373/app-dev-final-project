# == Schema Information
#
# Table name: portfolios
#
#  id             :integer          not null, primary key
#  day            :date
#  portfoliovalue :decimal(, )
#  return         :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#
class Portfolio < ApplicationRecord
  validates(:portfoliovalue, {:uniqueness => {:scope => [:user_id, :day], :allow_nil => false}})
  validates(:portfoliovalue, {:presence => true})
  
  
  #has_many(:portfolio_weight, class_name: 'Portfolio_Weight', foreign_key: 'ticker')
  #belongs_to(:user, class_name='User', foreign_key='user_id')

  


end
