Rails.application.routes.draw do
  # Routes for the Portfolio resource:

  # CREATE
  post("/insert_portfolio", { :controller => "portfolios", :action => "create" })
          
  # READ
  get("/portfolios", { :controller => "portfolios", :action => "index" })
  
  get("/portfolios/:path_id", { :controller => "portfolios", :action => "show" })
  
  # UPDATE
  
  post("/modify_portfolio/:path_id", { :controller => "portfolios", :action => "update" })
  
  # DELETE
  get("/delete_portfolio/:path_id", { :controller => "portfolios", :action => "destroy" })

  #------------------------------

  # Routes for the Stock resource:

  # CREATE
  post("/insert_stock", { :controller => "stocks", :action => "create" })
          
  # READ
  get("/stocks", { :controller => "stocks", :action => "index" })
  
  get("/stocks/:path_id", { :controller => "stocks", :action => "show" })
  
  # UPDATE
  
  post("/modify_stock/:path_id", { :controller => "stocks", :action => "update" })
  
  # DELETE
  get("/delete_stock/:path_id", { :controller => "stocks", :action => "destroy" })

  #------------------------------

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
