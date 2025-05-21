require 'json'
require 'yaml'

module QuizVCh
  class Question
    attr_accessor :question_body, :question_correct_answer, :original_answers

    def initialize(raw_text, raw_answers)
      @question_body = raw_text
      @question_correct_answer = raw_answers.first
      @original_answers = raw_answers
    end

    # Генерує новий хеш із перемішаними відповідями для кожного показу
    def shuffled_answers
      shuffled = @original_answers.shuffle
      keys = (1..shuffled.size).map(&:to_s)
      Hash[keys.zip(shuffled)]
    end

    def display_answers(shuffled_hash)
      shuffled_hash.map { |char, answer| "#{char}. #{answer}" }
    end

    def to_s
      @question_body.to_s
    end

    def to_h
      {
        question_body: @question_body,
        question_correct_answer: @question_correct_answer,
        question_answers: @original_answers
      }
    end

    def to_json(*_args)
      to_h.to_json
    end

    def to_yaml
      to_h.to_yaml
    end

    # Пошук відповіді за номером у поточному перемішаному хеші
    def find_answer_by_char(char, shuffled_hash)
      shuffled_hash[char]
    end
  end
end