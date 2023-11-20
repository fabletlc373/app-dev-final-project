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
end
