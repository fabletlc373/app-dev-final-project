class PortfoliosController < ApplicationController
  def norm_weights(w)
    # rescales weights to 0-1 scale
    # takes in an array
    the_sum = w.sum(0.0)
    if the_sum!=1 then
      return w.map{|a| a/the_sum}
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
    if current_user != nil && current_user.has_portfolio==false then
      # assumes that each day you will hold the portfolio according to these weights
      weights = params.select{|k, v| k.include? "weights" and v.to_f!=0}
      # normalize the weights, if necessary
      new_weights = norm_weights(weights.values.map{|w| w.to_f})
      weights = Hash[weights.keys.map{|k| k.gsub(/_weights/, "")}.zip(new_weights)]
      # first, insert each weight for the initial date
      weights.each do |s, w|
        init_portfolio = Portfolio.new
        init_portfolio.day = params.fetch("startdate")
        init_portfolio.ticker = s
        init_portfolio.weight = w
        init_portfolio.portfoliovalue = params.fetch("dollarval")
        init_portfolio.dollarpos = params.fetch("dollarval").to_f * w
        init_portfolio.user_id = current_user.id
        init_portfolio.return=0

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
        ptf_value_day = ptf_values[i]
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
    if current_user.has_portfolio==true && current_user!=nil then
      @current_user = current_user
      sql = "select distinct day, portfoliovalue, return from portfolios where user_id=#{current_user.id} and return!=0"
      @the_portfolio = ActiveRecord::Base.connection.exec_query(sql)

      sql = "select distinct day, portfoliovalue, return from portfolios where user_id=#{current_user.id} order by day desc limit 1"
      init_value = ActiveRecord::Base.connection.exec_query(sql).rows[0][1]

      # compute some additional statistics
      # get the returns first
      rets = @the_portfolio.rows.map{|r| (r[2]/100).round(2)}

      
      @annualized_ret, @annualized_std, @annualized_sr, cumu_rets = self.return_stats(rets)
      cumu_value = cumu_rets.map{|r| r * init_value}

      @cumu_rets = Hash[@the_portfolio.rows.map{|r| r[0]}.zip(cumu_value)]
      #asdf
      render({ :template => "portfolios/show" })
    else
      redirect_to("/build_portfolio", { :alert => "No portfolio found... build yours here!" })
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
    the_portfolio = Portfolio.where({ :user_id => the_id })
    the_portfolio.delete_all

    redirect_to("/build_portfolio", { :notice => "Portfolio deleted successfully." })
  end
end
