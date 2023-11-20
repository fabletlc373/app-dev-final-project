class StocksController < ApplicationController
  def index
    matching_stocks = Stock.all

    @list_of_stocks = matching_stocks.order({ :created_at => :desc })

    render({ :template => "stocks/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_stocks = Stock.where({ :id => the_id })

    @the_stock = matching_stocks.at(0)

    render({ :template => "stocks/show" })
  end

  def create
    the_stock = Stock.new
    the_stock.day = params.fetch("query_day")
    the_stock.close = params.fetch("query_close")
    the_stock.open = params.fetch("query_open")
    the_stock.high = params.fetch("query_high")
    the_stock.low = params.fetch("query_low")
    the_stock.return = params.fetch("query_return")

    if the_stock.valid?
      the_stock.save
      redirect_to("/stocks", { :notice => "Stock created successfully." })
    else
      redirect_to("/stocks", { :alert => the_stock.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_stock = Stock.where({ :id => the_id }).at(0)

    the_stock.day = params.fetch("query_day")
    the_stock.close = params.fetch("query_close")
    the_stock.open = params.fetch("query_open")
    the_stock.high = params.fetch("query_high")
    the_stock.low = params.fetch("query_low")
    the_stock.return = params.fetch("query_return")

    if the_stock.valid?
      the_stock.save
      redirect_to("/stocks/#{the_stock.id}", { :notice => "Stock updated successfully."} )
    else
      redirect_to("/stocks/#{the_stock.id}", { :alert => the_stock.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_stock = Stock.where({ :id => the_id }).at(0)

    the_stock.destroy

    redirect_to("/stocks", { :notice => "Stock deleted successfully."} )
  end
end