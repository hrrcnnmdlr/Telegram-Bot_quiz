require 'yaml'
require 'json'
require_relative '../../models/questions'

module QuizVCh
  class QuestionStruct # ← перейменовано!
    attr_reader :question_body, :original_answers, :question_correct_answer

    def initialize(question_body, original_answers)
      @question_body = question_body
      @original_answers = original_answers
      @question_correct_answer = original_answers.first # або інша логіка
    end

    def to_h
      {
        question_body: @question_body,
        original_answers: @original_answers,
        question_correct_answer: @question_correct_answer
      }
    end
  end

  class QuestionData
    attr_accessor :collection, :yaml_dir, :in_ext, :threads

    def initialize(
      yaml_dir: File.expand_path('../../config/quiz_yml', __dir__),
      in_ext: '*.yml'
    )
      @collection = []
      @yaml_dir = yaml_dir
      @in_ext = in_ext
      @threads = []
      load_data
      save_to_db
    end

    def to_yaml
      @collection.map(&:to_h).to_yaml
    end

    def save_to_yaml(filename = File.expand_path('../../log/questions_dump.yml', __dir__))
      File.write(filename, to_yaml)
    end

    def to_json
      @collection.map(&:to_h).to_json
    end

    def save_to_json(filename = File.expand_path('../../log/questions_dump.json', __dir__))
      File.write(filename, to_json)
    end

    def each_file(&block)
      Dir.glob(File.join(@yaml_dir, @in_ext)).each(&block)
    end

    def in_thread(&block)
      @threads << Thread.new(&block)
    end

    def load_data
      each_file do |filename|
        in_thread { load_from(filename) }
      end
      @threads.each(&:join)
    end

    def load_from(filename)
      data = YAML.load_file(filename)
      data.each do |item|
        question_text = item['question']
        answers = item['answers']
        next unless question_text && answers.is_a?(Array) && !answers.empty?
        question = QuestionStruct.new(question_text, answers) # ← тут теж!
        @collection << question
      end
    end

    def save_to_db
      ::Question.delete_all # ← використовуємо саме ActiveRecord-модель
      @collection.each do |q|
        ::Question.create(
          body: q.question_body,
          answers: q.original_answers.to_yaml,
          correct_answer: q.question_correct_answer
        )
      end
    end

    def save_to_files
      # Зберегти у JSON
      File.write('log/testing.json', JSON.pretty_generate(@collection.map(&:to_h)))
      # Зберегти у YAML
      File.write('log/testing.yml', YAML.dump(@collection.map(&:to_h)))
    end
  end
end

def collection
  files = Dir[File.expand_path('../../config/quiz_yml/*.yml', __dir__)].sort
  files.flat_map do |file|
    YAML.load_file(file).map do |q|
      OpenStruct.new(
        question_body: q['question'],
        original_answers: q['answers'],
        question_correct_answer: q['correct'] || q['answers'].first
      )
    end
  end
end
