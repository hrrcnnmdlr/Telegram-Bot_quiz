require_relative 'libraries'

module QuizVCh
  class Runner
    def initialize
      @engine = QuizVCh::Engine.new
    end

    def start
      puts "Starting the quiz..."
      @engine.run
    end
  end
end

if __FILE__ == $0
  QuizVCh::Runner.new.start
end