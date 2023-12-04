Rails.application.routes.draw do
  devise_for :users
  # Routes for the Portfolio resource:

  # CREATE
  get("/build_portfolio", { :controller => "portfolios", :action => "build" })
  post("/create_portfolio", { :controller => "portfolios", :action => "create"})
          
  # view
  get("/my_portfolio", { :controller => "portfolios", :action => "show" })
  
  # DELETE
  get("/delete_portfolio/:path_id", { :controller => "portfolios", :action => "destroy" })

  # REFRESH
  get("/refresh_portfolio/:path_id", { :controller => "portfolios", :action => "refresh_data" })

  #------------------------------

  # Routes for the Stock resource:

  # CREATE
  post("/insert_stock", { :controller => "stocks", :action => "create" })
          
  # INDEX
  get("/stocks", { :controller => "stocks", :action => "index" })
  
  # DETAILS
  get("/stocks/:ticker", { :controller => "stocks", :action => "show" })
  
  # DELETE
  get("/delete_stock/:ticker", { :controller => "stocks", :action => "destroy" })

  # REFRESH
  get("/refresh_stock", { :controller => "stocks", :action => "refresh_data" })


  #------------------------------

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "stocks#index"
end
