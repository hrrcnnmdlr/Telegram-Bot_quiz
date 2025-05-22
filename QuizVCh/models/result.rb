require 'active_record'

class Result < ActiveRecord::Base
  belongs_to :user
end