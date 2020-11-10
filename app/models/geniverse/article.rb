module Geniverse
  class Article < ActiveRecord::Base
    belongs_to :activity
  end
end
