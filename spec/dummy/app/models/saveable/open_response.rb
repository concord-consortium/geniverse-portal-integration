class Saveable::OpenResponse < ActiveRecord::Base
  belongs_to :learner, :class_name => 'Portal::Learner'
  belongs_to :offering, :class_name => 'Portal::Offering'
  belongs_to :open_response, :class_name => 'Embeddable::OpenResponse'

  has_many :answers, :class_name => 'Saveable::OpenResponseAnswer', -> { order(:position) }

  delegate :prompt, :to => :open_response, :class_name => 'Embeddable::OpenResponse'

  def answer
    if answered?
      answers.last.answer
    else
      "not answered"
    end
  end

  def answered?
    answers.length > 0
  end
end
