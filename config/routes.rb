Rails.application.routes.draw do
	require 'sidekiq/web'
	mount Sidekiq::Web => "/asfldkj123k8123ljadsf/tradies"
	root 'static_pages#landing'
	# get 'static_pages/autocomplete/*query', to: 'static_pages#autocomplete'
	get	 'messages/new/:id',			to: 'messages#new' 
	get	 'users/oauth/:id',				to: 'users#oauth'
	get  'users/posts/:id', 			to: 'users#posts'
	get	 'posts/mark_as_sold/:id',		to: 'posts#mark_as_sold'
	get	 'posts/interested/:id',		to: 'posts#interested'
	get	 'posts/photos/:id',			to: 'posts#post_attachments'
	get	 'posts/not_interested/:id',	to: 'posts#not_interested'
	get	 'posts/buy/:id',				to: 'posts#buy'
	get	 'posts/payment_success/:id',	to: 'posts#payment_success'
	# get  '/done',    	 				to: 'static_pages#finished_tutorial'
	get  '/landing',    	 			to: 'static_pages#landing'
	get  '/home',    	 				to: 'static_pages#home'
	get  '/no_thanks',    	 				to: 'static_pages#no_thanks'
	# get  '/change_location',    	 	to: 'static_pages#change_location'
	get '/search/*query', 				to: 'static_pages#home', as: :search
	get  '/help',    	 				to: 'static_pages#help'
	# get  '/about',   	 				to: 'static_pages#about'
	get  '/contact',   					to: 'static_pages#contact'
	# get  '/upgrades',					to: 'static_pages#upgrades'
	get  '/TermsOfUse',					to: 'static_pages#TermsOfUse'
	get  '/prohibited',					to: 'static_pages#prohibited'
	get  '/PrivacyPolicy',					to: 'static_pages#PrivacyPolicy'
	# get  '/upgrades/buy/:id',			to: 'upgrades#buy'
	# get  '/upgrades/payment_success/:id',	to: 'upgrades#payment_success'
	get  '/signup',  	  				to: 'users#new'
	post '/signup', 					to: 'users#create'
	get    '/login',   					to: 'sessions#new'
	post   '/login',   					to: 'sessions#create'
	delete '/logout',  					to: 'sessions#destroy'



	resources :users do
		resources :reviews,  			only: [ :show, :new, :create, :edit, :update, :destroy]	
	end
	# conversations
	resources :conversations, only: [:index, :show, :destroy] do
    	member do
	      post :reply
	      post :restore
	      post :mark_as_read
	    end
	    collection do
	      delete :empty_trash
	    end
	end
	# messages
	resources :messages, only: [:create]
	resources :post_attachments, 	only: [:new, :show, :edit, :update, :create, :destroy]
	
	# resources :interested_users_lists, 	only: [:new, :create, :destroy]
	# resources :interested_users, 	only: [:new, :create, :destroy]
	resources :posts, 				only: [:show, :create, :update, :destroy, :buy, :payment_success]

	resources :review_activations, only: [:edit]
	resources :account_activations, only: [:edit]
	resources :password_resets,     only: [:new,:edit,:create, :update]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
