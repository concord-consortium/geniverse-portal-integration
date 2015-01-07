module Geniverse
  class User < ActiveRecord::Base
    attr_protected :id
    validates_uniqueness_of(:username)

    serialize :metadata
  end
end
