require 'singleton'

module QuizBot
  class QuizBot
    include Singleton

    attr_accessor :yaml_dir, :log_dir

    def config
      yield self if block_given?
    end
  end
end