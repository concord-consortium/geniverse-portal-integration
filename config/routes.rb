Rails.application.routes.draw do
  namespace :geniverse do
    resources :help_messages, :articles, :cases, :activities, :dragons, :unlockables

    get 'destroy_all_dragons' => 'dragons#destroy_all'
    get 'fathom/:id/:id2' => 'dragons#fathom', :defaults => {:format => 'html', :id => '-1', :id2 => '-1'}
    get 'breedingRecords/:id/:id2' => 'dragons#breedingRecords', :defaults => {:format => 'html', :id => '-1', :id2 => '-1'}
    get 'breedingRecordsShow/:id' => 'dragons#breedingRecordsShow', :defaults => {:format => 'html'}

    # map username first, so usernames don't fall through and get interpreted as ids
    # usernames must start with an alpha character, but can have numbers or letters after that
    get 'users/:username' => "users#show", :constraints => { :username => /[a-z][a-z0-9]*/i }, :defaults => {:format => 'json'}

    resources :users, :except => :new
    get 'starsReport/:id' => 'users#starsReport'
  end
end
