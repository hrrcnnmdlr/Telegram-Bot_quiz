require 'active_record'

class UserAnswer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
end