class ApplicationController < ActionController::Base
  skip_forgery_protection

  def running_product(arr)
    result = 1
    running_products = []

    arr.each do |num|
      result *= num
      running_products << result.round(2)
    end

    running_products
  end

  def return_stats(rets)
    # remove cases where the return > 100%
    #bad_days = rets.map{|r| r <= 1}
    #rets = rets.selec}
    the_sum = rets.sum(0.0)
    the_size = rets.size
    the_mean = the_sum/the_size
    the_variance = rets.sum(0.0) { |element| (element - the_mean) ** 2 }/(the_size - 1)
    the_stddev = Math.sqrt(the_variance)
    
    # cumulative return
    cumu_rets = running_product(rets.map{|ret| 1 + ret})
    # annualized return
    annualized_ret = (the_mean*252).round(4) * 100 #((the_sum/the_size + 1)**252 -1 ).round(4) * 100
    # the annualized standard deviation
    annualized_std = (the_stddev * Math.sqrt(252) * 100).round(2)
    # the annualized Sharpe Ratio
    annualized_sr = (the_sum/the_size/the_stddev * Math.sqrt(252)).round(2)
    return annualized_ret, annualized_std, annualized_sr, cumu_rets
  end
  helper_method :return_stats

end
