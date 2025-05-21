require_relative 'libraries'

module QuizVCh
  class Engine
    def initialize
      @question_collection = QuestionData.new
      @question_collection.save_to_yaml("questions_dump.yml")
      @question_collection.save_to_json("questions_dump.json")
      @input_reader = InputReader.new
      @user_name = @input_reader.read(
        welcome_message: "Введіть ваше ім'я:",
        validator: ->(input) { !input.strip.empty? },
        error_message: "Ім'я не може бути порожнім."
      )
      @current_time = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
      @writer = FileWriter.new(
        "a", # <-- змініть "w" на "a"
        "#{@user_name}_#{@current_time}.txt"
      )
      @statistics = Statistics.new(@writer)
    end

    def run
      @writer.write("Ім'я користувача: #{@user_name}")
      @writer.write("Час початку: #{@current_time}")
      @question_collection.collection.each_with_index do |question, idx|
        shuffled = question.shuffled_answers
        puts "\nПитання #{idx + 1}: #{question}"
        @writer.write("\nПитання #{idx + 1}: #{question}")
        question.display_answers(shuffled).each do |ans|
          puts ans
          @writer.write(ans)
        end
        user_answer = get_answer_by_char(question, shuffled)
        correct = check(user_answer, question, shuffled)
        @writer.write("Ваша відповідь: #{user_answer} (#{question.find_answer_by_char(user_answer, shuffled)})")
        @writer.write("Правильна відповідь: #{question.question_correct_answer}")
        puts correct ? "Вірно!" : "Невірно!"
        @writer.write(correct ? "Вірно!" : "Невірно!")
      end
      @statistics.print_report(@question_collection.collection.size)
    end

    def get_answer_by_char(question, shuffled_hash)
      @input_reader.read(
        welcome_message: "Введіть номер відповіді (1-#{shuffled_hash.size}):",
        validator: ->(input) { shuffled_hash.key?(input.strip) },
        error_message: "Введіть коректний номер відповіді.",
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