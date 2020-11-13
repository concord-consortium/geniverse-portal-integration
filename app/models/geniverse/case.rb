module Geniverse
  class Case < ActiveRecord::Base
    has_many :activities, -> { order("myCaseOrder ASC") }, :foreign_key => :myCase_id,

    def includeInJSon?(name)
      return [:activities].include?(name.to_sym)
    end
  end
end
