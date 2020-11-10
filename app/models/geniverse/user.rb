module Geniverse
  class User < ActiveRecord::Base
    validates_uniqueness_of(:username)

    serialize :metadata
  end
end
