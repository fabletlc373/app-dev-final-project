class PortfoliosController < ApplicationController
  def index
    matching_portfolios = Portfolio.all

    @list_of_portfolios = matching_portfolios.order({ :created_at => :desc })

    render({ :template => "portfolios/index" })
  end

  def build
    @all_stocks = Stock.new.allstocks
    render({ :template => "portfolios/build" })
  end
  def show
    the_id = params.fetch("path_id")

    matching_portfolios = Portfolio.where({ :id => the_id })

    @the_portfolio = matching_portfolios.at(0)

    render({ :template => "portfolios/show" })
  end

  def create
    asdfas
    
    weights=params.keys.grep(/weights/)
    weights.each do |w|
      Portfolio.new
      Portfolio.day = params.fetch('startdate')
      s = w.gsub(/_weights/, '')   
      Portfolio.ticker = s
      Portfolio.weight = params.fetch(w)

    end



    the_portfolio = Portfolio.new
    the_portfolio.day = params.fetch("query_day")
    the_portfolio.stock_id = params.fetch("query_stock_id")
    the_portfolio.weight = params.fetch("query_weight")
    the_portfolio.dollarpos = params.fetch("query_dollarpos")
    the_portfolio.portfoliovalue = params.fetch("query_portfoliovalue")
    the_portfolio.user_id = params.fetch("query_user_id")

    if the_portfolio.valid?
      the_portfolio.save
      redirect_to("/portfolios", { :notice => "Portfolio created successfully." })
    else
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
      redirect_to("/portfolios/#{the_portfolio.id}", { :notice => "Portfolio updated successfully."} )
    else
      redirect_to("/portfolios/#{the_portfolio.id}", { :alert => the_portfolio.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_portfolio = Portfolio.where({ :id => the_id }).at(0)

    the_portfolio.destroy

    redirect_to("/portfolios", { :notice => "Portfolio deleted successfully."} )
  end
end
