require 'active_record'

class QuizTest < ActiveRecord::Base
  belongs_to :user
end