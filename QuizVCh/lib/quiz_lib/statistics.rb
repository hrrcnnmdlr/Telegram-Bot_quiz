module QuizVCh
  class Statistics
    attr_reader :correct_answers, :incorrect_answers

    def initialize(writer)
      @correct_answers = 0
      @incorrect_answers = 0
      @writer = writer
    end

    def correct_answer
      @correct_answers += 1
    end

    def incorrect_answer
      @incorrect_answers += 1
    end

    def print_report(total_questions)
      percent = total_questions.zero? ? 0 : ((@correct_answers.to_f / total_questions) * 100).round(2)
      report = <<~REPORT
        #{I18n.t(:test_summary, default: "Підсумки тесту:")}
        #{I18n.t(:correct_answers, default: "Коректних відповідей")}: #{@correct_answers}
        #{I18n.t(:incorrect_answers, default: "Некоректних відповідей")}: #{@incorrect_answers}
        #{I18n.t(:total_questions, default: "Всього питань")}: #{total_questions}
        #{I18n.t(:correct_percent, default: "Відсоток коректних відповідей")}: #{percent}%
      REPORT
      puts report
      @writer.write(report)
    end
  end
end