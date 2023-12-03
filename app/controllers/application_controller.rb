class ApplicationController < ActionController::Base
  skip_forgery_protection
  def return_stats(rets)
    the_sum = rets.sum(0.0)
    the_size = rets.size
    the_mean = the_sum/the_size
    the_variance = rets.sum(0.0) { |element| (element - the_mean) ** 2 }/(the_size - 1)
    the_stddev = Math.sqrt(the_variance)
    
    # cumulative return
    
    # annualized return
    annualized_ret = (the_mean*252).round(4) * 100 #((the_sum/the_size + 1)**252 -1 ).round(4) * 100

    # the annualized standard deviation
    annualized_std = (the_stddev * Math.sqrt(252) * 100).round(2)
    # the annualized Sharpe Ratio
    annualized_sr = (the_sum/the_size/the_stddev * Math.sqrt(252)).round(2)
    return annualized_ret, annualized_std, annualized_sr
  end

end
