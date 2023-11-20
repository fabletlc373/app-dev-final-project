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
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Stock < ApplicationRecord
end
