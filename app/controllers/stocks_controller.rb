class StocksController < ApplicationController
  def refresh_data
    the_date = Date.today
    # refresh all stocks in the universe
    all_stocks = Stock.distinct.pluck(:ticker)
    all_stocks.each do |s|
      next if Stock.where('ticker=? AND day=?', s, the_date).count > 0
      api_url = "https://api.twelvedata.com/time_series?symbol=#{s}&interval=1day&apikey=#{ENV['STOCK_API_KEY']}"

      raw_data = HTTP.get(api_url)
      parsed_data = JSON.parse(raw_data)
      all_prices_array = parsed_data.fetch('values')
      all_prices_array = all_prices_array.map{|x| x.except('volume')}
      all_prices_array = all_prices_array.each{|h| h.store('day',h.delete('datetime'))}
      all_prices_array.each{|x| x['ticker']=s}
      all_prices_array.each_cons(2).map{|p1, p2| p1['return'] = (((p1['close'].to_f / p2['close'].to_f) - 1)*100).round(3)}
      all_prices_array.last['return'] = 0
      Stock.create(all_prices_array)
    end 
    redirect_to("/stocks")
  end
  
  def index
    @list_of_stocks = Stock.new.lastsnap
    render({ :template => "stocks/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_stocks = Stock.where({ :id => the_id })

    @the_stock = matching_stocks.at(0)

    render({ :template => "stocks/show" })
  end

  def create
    # insert a new stock into the db
    # assumption is the data already exists
    # pull data as far back as possible
  newstock = params.fetch("query_ticker")
    # insert_all
    # however the base assumption here is there is no data for this stock in the first place, so do not need to check prior to insert

    check_cnt = Stock.where(:ticker=>newstock).count
    if check_cnt==0
      api_url = "https://api.twelvedata.com/time_series?symbol=#{newstock}&interval=1day&apikey=#{ENV['STOCK_API_KEY']}&start_date=1980-01-01&…"

      raw_data = HTTP.get(api_url)
      parsed_data = JSON.parse(raw_data)
      all_prices_array = parsed_data.fetch('values')
      all_prices_array = all_prices_array.map{|x| x.except('volume')}
      all_prices_array = all_prices_array.each{|h| h.store('day',h.delete('datetime'))}
      all_prices_array.each{|x| x['ticker']=newstock}
      all_prices_array.each_cons(2).map{|p1, p2| p1['return'] = (((p1['close'].to_f / p2['close'].to_f) - 1)*100).round(3)}
      all_prices_array.last['return'] = 0
      Stock.insert_all(all_prices_array)
      redirect_to("/stocks")
    else
      redirect_to("/stocks", { :alert => "stock already exists!" })
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
