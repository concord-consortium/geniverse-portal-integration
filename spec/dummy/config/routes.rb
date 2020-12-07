Rails.application.routes.draw do

  get '/home' => 'home#index', :as => :home
  root :to => 'home#index'
end
