require 'active_record'

class User < ActiveRecord::Base
  has_many :quiz_tests
  has_many :user_answers
  has_many :results
end