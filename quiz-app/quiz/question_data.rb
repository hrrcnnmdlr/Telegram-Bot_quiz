require 'yaml'
require 'json'

module QuizVCh
  class QuestionData
    attr_accessor :collection, :yaml_dir, :in_ext, :threads

    def initialize(yaml_dir: File.expand_path('yml', __dir__), in_ext: '*.yml')
      @collection = []
      @yaml_dir = yaml_dir
      @in_ext = in_ext
      @threads = []
      load_data
    end

    def to_yaml
      @collection.map(&:to_h).to_yaml
    end

    def save_to_yaml(filename)
      File.write(prepare_filename(filename), to_yaml)
    end

    def to_json
      @collection.map(&:to_h).to_json
    end

    def save_to_json(filename)
      File.write(prepare_filename(filename), to_json)
    end

    def prepare_filename(filename)
      File.expand_path(filename, @yaml_dir)
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
        question = Question.new(question_text, answers)
        @collection << question
      end
    end
  end
end