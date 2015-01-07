module Geniverse
  class Article < ActiveRecord::Base
    attr_protected :id
    belongs_to :activity
  end
end
