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
# Indexes
#
#  index_stocks_on_day_and_ticker  (day,ticker)
#
class Stock < ApplicationRecord
  validates(:ticker, {:uniqueness => {:scope => [:day], :allow_nil => false}})
  # validates(:day, {:uniqueness => {:scope => [:id]}})
  belongs_to(:portfolio, class_name: 'Portfolio', foreign_key: 'ticker')

  def lastsnap
    qry = "select *
    from stocks 
    group by ticker
    having max(day)
    order by day
    "
    the_data = Stock.connection.execute(qry)
    
    return the_data
  end

  def allstocks
    return Stock.distinct.pluck(:ticker)
  end

  # check if this stock is used in ANY portfolio
  
end
