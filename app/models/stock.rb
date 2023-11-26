# == Schema Information
#
# Table name: stocks
#
#  id         :integer          not null, primary key
#  close      :decimal(, )
#  day        :date
#  high       :decimal(, )
#  low        :decimal(, )
#  open       :decimal(, )
#  return     :decimal(, )
#  ticker     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Stock < ApplicationRecord
  validates(:ticker, {:uniqueness => {:scope => [:id, :day]}})
  validates(:day, {:uniqueness => {:scope => [:id]}})
end
