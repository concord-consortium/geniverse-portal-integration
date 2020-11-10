module Geniverse
  class Activity < ActiveRecord::Base
    has_many :dragons
    belongs_to :myCase, :foreign_key => :myCase_id, :class_name => "Case"
  end
end
