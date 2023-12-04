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
      init_weight = Portfolio_Weigh.new
      init_weight.weight = w
        
        if init_portfolio.valid?
          init_portfolio.save
        end
        #Portfolio.dollarpos = params.fetch(w)
      end

      # compute the daily returns... its easier to do this directly via sql
      # todo, renormalize weights when value is missing
      # can we do the loading/computation all in 1?
      sql = "select stocks.day as day, sum(weight * stocks.return) as return from portfolios
    right join stocks
    on stocks.ticker=portfolios.ticker and portfolios.user_id=#{current_user.id}
    where portfolios.weight!=0 and stocks.day > '#{params.fetch("startdate")}'
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
        weights.each do |s, w|
          d_portfolio = Portfolio.new
          d_portfolio.day = d
          d_portfolio.ticker = s
          d_portfolio.weight = w
          d_portfolio.portfoliovalue = ptf_value_day
          d_portfolio.dollarpos = ptf_value_day * w
          d_portfolio.user_id = current_user.id
          d_portfolio.return = ptf_return_day
          if d_portfolio.valid?
            d_portfolio.save
          end
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
      sql = "select distinct day, portfoliovalue, return from portfolios where user_id=#{current_user.id} and return!=0"
      @the_portfolio = ActiveRecord::Base.connection.exec_query(sql)

      #sql = "select distinct day, portfoliovalue, return from portfolios where user_id=#{current_user.id} order by day desc limit 1"
      #init_value = ActiveRecord::Base.connection.exec_query(sql).rows[0][1]

      # compute some additional statistics
      # get the returns first
      rets = @the_portfolio.rows.map { |r| (r[2] / 100).round(2) }

      @annualized_ret, @annualized_std, @annualized_sr, cumu_rets = self.return_stats(rets)
      cumu_value = @the_portfolio.rows.map{|r| r[1]}#cumu_rets.map { |r| r}# * init_value }

      @cumu_rets = Hash[@the_portfolio.rows.map { |r| r[0] }.zip(cumu_value)]
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

    sql = "select distinct portfolios.ticker, weight
    from portfolios
    where portfolios.user_id=#{the_id}
    and portfolios.weight!=0"
    results = ActiveRecord::Base.connection.exec_query(sql)
    weights = Hash[results.rows]


    sql = "select stocks.day as day, sum(weight * stocks.return) as return, portfoliovalue from portfolios
    right join stocks
    on stocks.ticker=portfolios.ticker and stocks.day=portfolios.day and portfolios.user_id=#{the_id}
    where portfolios.weight!=0 and stocks.day >= '#{(start_day-1).strftime}' and stocks.day <= '#{last_day}'
    group by stocks.day
    order by stocks.day asc"

    results = ActiveRecord::Base.connection.exec_query(sql)
    ptf_dates = results.rows.map { |ret| ret[0] }.drop(1)
    ptf_returns = results.rows.map { |ret| ret[1] }.drop(1)
    # the first elemement is the previous value
    # all elements after are 1+
    ptf_values = self.running_product(ptf_returns.map { |ret| 1 + ret / 100 }).drop(1)
    asdf

    # load the values back into the db
    ptf_dates.each do |d|
      i = ptf_dates.index(d)
      ptf_value_day = ptf_values[i] *  results.rows[0][2]
      ptf_return_day = ptf_returns[i]
      weights.each do |s, w|
        d_portfolio = Portfolio.new
        d_portfolio.day = d
        d_portfolio.ticker = s
        d_portfolio.weight = w
        d_portfolio.portfoliovalue = ptf_value_day
        d_portfolio.dollarpos = ptf_value_day * w
        d_portfolio.user_id = current_user.id
        d_portfolio.return = ptf_return_day
        if d_portfolio.valid?
          d_portfolio.save
        end
      end
    end
    redirect_to("/my_portfolio", { :notice => "Portfolio updated successfully." })
  end

  def destroy
    the_id = params.fetch("path_id")
    the_portfolio = Portfolio.where({ :user_id => the_id })
    the_portfolio.delete_all

    redirect_to("/build_portfolio", { :notice => "Portfolio deleted successfully." })
  end
end
