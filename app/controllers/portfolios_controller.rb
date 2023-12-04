class PortfoliosController < ApplicationController
  def norm_weights(w)
    # rescales weights to 0-1 scale
    # takes in an array
    the_sum = w.sum(0.0)
    if the_sum != 1
      return w.map { |a| a / the_sum }
    else
      return w
    end
  end

  def build
    @all_stocks = Stock.new.allstocks
    render({ :template => "portfolios/build" })
  end

  def create
    # check if the user current has a portfolio, if they do, redirect to the portfolio home page
    if current_user != nil && current_user.has_portfolio == false
      # assumes that each day you will hold the portfolio according to these weights
      weights = params.select { |k, v| k.include? "weights" and v.to_f != 0 }
      # normalize the weights, if necessary
      new_weights = norm_weights(weights.values.map { |w| w.to_f })
      weights = Hash[weights.keys.map { |k| k.gsub(/_weights/, "") }.zip(new_weights)]

      # first, insert each weight
      weights.each do |s, w|
        init_weight = PortfolioWeight.new
        init_weight.weight = w
        init_weight.ticker = s
        init_weight.user_id = current_user.id

        if init_weight.valid?
          init_weight.save
        end
      end

      # insert the init value
      init_val = PortfolioInitValue.new
      init_val.init_value = params.fetch("dollarval")
      init_val.user_id = current_user.id

      # compute the daily returns... its easier to do this directly via sql
      # todo, renormalize weights when value is missing
      # can we do the loading/computation all in 1?
      sql = "select stocks.day as day, sum(weight * stocks.return) as return 
      from stocks
      left join portfolio_weights
      on stocks.ticker=portfolio_weights.ticker and portfolio_weights.user_id=#{current_user.id}
      where portfolio_weights.weight!=0 and stocks.day > '#{params.fetch("startdate")}'
      group by stocks.day"
      results = ActiveRecord::Base.connection.exec_query(sql)
      ptf_dates = results.rows.map { |ret| ret[0] }
      ptf_returns = results.rows.map { |ret| ret[1] }
      ptf_values = self.running_product(ptf_returns.map { |ret| 1 + ret / 100 })
      # load the values back into the db
      ptf_dates.each do |d|
        i = ptf_dates.index(d)
        ptf_value_day = ptf_values[i] * params.fetch("dollarval").to_f
        ptf_return_day = ptf_returns[i]
        d_portfolio = Portfolio.new
        d_portfolio.day = d
        d_portfolio.portfoliovalue = ptf_value_day
        d_portfolio.user_id = current_user.id
        d_portfolio.return = ptf_return_day
        if d_portfolio.valid?
          d_portfolio.save
        end
      end
      redirect_to("/my_portfolio", { :notice => "Portfolio created successfully." })
    else
      # redirect to actual portfolio page
      redirect_to("/my_portfolio", { :alert => "A portfolio already exists!" })
    end
  end

  def show
    # check if has portfolio
    if current_user.has_portfolio == true && current_user != nil
      @current_user = current_user
      @the_portfolio = Portfolio.where(user_id: current_user.id).where('return!=?', 0)
      
      # compute some additional statistics
      # get the returns first
      @years = @the_portfolio.pluck(:day).map { |d| d.year }.uniq
      rets = (@the_portfolio.pluck(:return).map { |ret| (ret / 100).round(2)})

      @annualized_ret, @annualized_std, @annualized_sr, cumu_rets = self.return_stats(rets)
      @cumu_values = Hash[@the_portfolio.pluck(:day).zip(@the_portfolio.pluck(:portfoliovalue))] 
      
      render({ :template => "portfolios/show" })
    else
      redirect_to("/build_portfolio", { :alert => "No portfolio found... build yours here!" })
    end
  end

  # assumes all stocks are already refreshed
  # start_day - 1 is fully updated
  def refresh_data
    the_id = params.fetch("path_id")
    sql = "select max(day) as maxdays, min(day) as mindays
    from stocks
    where stocks.return!=0"
    results = ActiveRecord::Base.connection.exec_query(sql)
    last_day = results.rows.last[0]
    start_day = last_day.to_date - 30
    start_day_m1 = start_day - 1
    init_value = Portfolio.where(user_id: the_id, day: start_day_m1.strftime("%Y-%m-%d")).first.fetch("portfoliovalue")
    sql = "
    select stocks.day as day, sum(weight * stocks.return) as return
    from stocks
    right join portfolio_weights
    on stocks.ticker=portfolio_weights.ticker and portfolio_weights.user_id=#{current_user.id}
    where portfolio_weights.weight!=0 and stocks.day between '#{start_day.strftime}' and '#{last_day}'
    group by stocks.day
    order by stocks.day asc"

    results = ActiveRecord::Base.connection.exec_query(sql)
    ptf_dates = results.rows.map { |ret| ret[0] }
    ptf_returns = results.rows.map { |ret| ret[1] }
    # the first elemement is the previous value
    # all elements after are 1+
    ptf_values = self.running_product(ptf_returns.map { |ret| 1 + ret / 100 })

    # load the values back into the db
    ptf_dates.each do |d|
      i = ptf_dates.index(d)
      ptf_value_day = ptf_values[i] * init_value
      ptf_return_day = ptf_returns[i]
      d_portfolio = Portfolio.new
      d_portfolio.day = d
      d_portfolio.portfoliovalue = ptf_value_day
      d_portfolio.user_id = current_user.id
      d_portfolio.return = ptf_return_day
      if d_portfolio.valid?
        d_portfolio.save
      end
    end
    redirect_to("/my_portfolio", { :notice => "Portfolio updated successfully." })
  end

  def destroy
    the_id = params.fetch("path_id")
    the_portfolio = Portfolio.where({ :user_id => the_id })
    the_portfolio.delete_all

    the_portfolio = PortfolioWeight.where({ :user_id => the_id })
    the_portfolio.delete_all

    the_portfolio = PortfolioInitValue.where({ :user_id => the_id })
    the_portfolio.delete_all

    redirect_to("/build_portfolio", { :notice => "Portfolio deleted successfully." })
  end
end
