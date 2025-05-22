require 'singleton'

module QuizVCh
  class Quiz
    include Singleton

    attr_accessor :yaml_dir, :in_ext, :answers_dir, :log_dir

    def config
      yield self if block_given?
    end
  end
end