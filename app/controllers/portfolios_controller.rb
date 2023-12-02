class PortfoliosController < ApplicationController
  def running_product(arr)
    result = 1
    running_products = []

    arr.each do |num|
      result *= num
      running_products << result
    end

    running_products
  end

  def show
    # check if has portfolio
    if current_user.has_portfolio && current_user!=nil then
      #todo: add the returns to this table
      @the_portfolio = Portfolio.where({:user_id => current_user.id}).select('DISTINCT day, portfoliovalue, return')
      render({ :template => "portfolios/show" })
      # consider redirecting
    else
    end
    
  end

  def build
    @all_stocks = Stock.new.allstocks
    render({ :template => "portfolios/build" })
  end

  def create
    # check if the user current has a portfolio, if they do, redirect to the portfolio home page
    if current_user != nil && current_user.has_portfolio == FALSE

      # assumes that each day you will hold the portfolio according to these weights
      weights = params.keys.grep(/weights/)
      # first, insert each weight for the initial date
      weights.each do |w|
        init_portfolio = Portfolio.new
        init_portfolio.day = params.fetch("startdate")
        s = w.gsub(/_weights/, "")
        init_portfolio.ticker = s
        init_portfolio.weight = params.fetch(w)
        init_portfolio.portfoliovalue = params.fetch("dollarval")
        init_portfolio.dollarpos = params.fetch("dollarval").to_f * params.fetch(w).to_f
        init_portfolio.user_id = current_user.id
        if init_portfolio.valid?
          init_portfolio.save
        end
        #Portfolio.dollarpos = params.fetch(w)
      end

      # compute the daily returns... its easier to do this directly via sql

      sql = "select stocks.day as day, sum(weight * return) as return from portfolios
    right join stocks
    on stocks.ticker=portfolios.ticker and portfolios.user_id=#{current_user.id}
    where portfolios.weight!=0 and stocks.day > '#{params.fetch("startdate")}'
    group by stocks.day"
      results = ActiveRecord::Base.connection.exec_query(sql)
      ptf_dates = results.rows.map { |ret| ret[0] }
      ptf_returns = results.rows.map { |ret| ret[1] }
      ptf_values = running_product(ptf_returns.map { |ret| 1 + ret / 100 })

      # load the values back into the db
      ptf_dates.each do |d|
        i = ptf_dates.index(d)
        ptf_value_day = ptf_values[i]
        weights.each do |w|
          d_portfolio = Portfolio.new
          d_portfolio.day = d
          s = w.gsub(/_weights/, "")
          d_portfolio.ticker = s
          d_portfolio.weight = params.fetch(w)
          d_portfolio.portfoliovalue = ptf_value_day
          d_portfolio.dollarpos = ptf_value_day * params.fetch(w).to_f
          d_portfolio.user_id = current_user.id
          if d_portfolio.valid?
            d_portfolio.save
          end
        end
      end
      redirect_to("/portfolios", { :notice => "Portfolio created successfully." })
    else
      # redirect to actual portfolio page
      redirect_to("/portfolios", { :alert => the_portfolio.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_portfolio = Portfolio.where({ :id => the_id }).at(0)

    the_portfolio.day = params.fetch("query_day")
    the_portfolio.stock_id = params.fetch("query_stock_id")
    the_portfolio.weight = params.fetch("query_weight")
    the_portfolio.dollarpos = params.fetch("query_dollarpos")
    the_portfolio.portfoliovalue = params.fetch("query_portfoliovalue")
    the_portfolio.user_id = params.fetch("query_user_id")

    if the_portfolio.valid?
      the_portfolio.save
      redirect_to("/portfolios/#{the_portfolio.id}", { :notice => "Portfolio updated successfully." })
    else
      redirect_to("/portfolios/#{the_portfolio.id}", { :alert => the_portfolio.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_portfolio = Portfolio.where({ :id => the_id }).at(0)

    the_portfolio.destroy

    redirect_to("/portfolios", { :notice => "Portfolio deleted successfully." })
  end
end
