require 'i18n'
require_relative 'quiz_libraries'

I18n.load_path << File.expand_path('../../config/locales.yml', __dir__)
I18n.default_locale = :ua # або :en

module QuizVCh
  class Engine
    def initialize
      @question_collection = QuestionData.new
      @question_collection.save_to_yaml("questions_dump.yml")
      @question_collection.save_to_json("questions_dump.json")
      @question_collection.save_to_db
      @input_reader = InputReader.new
      @user_name = @input_reader.read(
        welcome_message: I18n.t(:enter_name),
        validator: ->(input) { !input.strip.empty? },
        error_message: I18n.t(:empty_name)
      )
      @current_time = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
      @writer = FileWriter.new(
        "a",
        "#{@user_name}_#{@current_time}.txt"
      )
      @statistics = Statistics.new(@writer)
    end

    def run
      @writer.write("#{I18n.t(:user_name)}: #{@user_name}")
      @writer.write("#{I18n.t(:start_time)}: #{@current_time}")
      @question_collection.collection.each_with_index do |question, idx|
        shuffled = question.shuffled_answers
        puts "\n#{I18n.t(:question)} #{idx + 1}: #{question}"
        @writer.write("\n#{I18n.t(:question)} #{idx + 1}: #{question}")
        question.display_answers(shuffled).each do |ans|
          puts ans
          @writer.write(ans)
        end
        user_answer = get_answer_by_char(question, shuffled)
        correct = check(user_answer, question, shuffled)
        @writer.write("#{I18n.t(:your_answer)}: #{user_answer} (#{question.find_answer_by_char(user_answer, shuffled)})")
        @writer.write("#{I18n.t(:correct_answer)}: #{question.question_correct_answer}")
        puts correct ? I18n.t(:right) : I18n.t(:wrong)
        @writer.write(correct ? I18n.t(:right) : I18n.t(:wrong))
      end
      @statistics.print_report(@question_collection.collection.size)
    end

    def get_answer_by_char(question, shuffled_hash)
      @input_reader.read(
        welcome_message: I18n.t(:enter_answer_number, count: shuffled_hash.size),
        validator: ->(input) { shuffled_hash.key?(input.strip) },
        error_message: I18n.t(:invalid_answer_number),
        process: ->(input) { input.strip }
      )
    end

    def check(user_answer, question, shuffled_hash)
      user_value = question.find_answer_by_char(user_answer, shuffled_hash)
      if user_value && user_value.strip == question.question_correct_answer.strip
        @statistics.correct_answer
        true
      else
        @statistics.incorrect_answer
        false
      end
    end
  end
end