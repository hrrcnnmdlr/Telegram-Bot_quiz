module QuizVCh
  class FileWriter
    def initialize(mode, filename, answers_dir = File.expand_path('../../quiz_answers', __dir__))
      @answers_dir = answers_dir
      @filename = prepare_filename(filename)
      @mode = mode
    end

    def write(message)
      File.open(@filename, @mode) do |file|
        file.puts message
      end
    end

    def prepare_filename(filename)
      File.expand_path(filename, @answers_dir)
    end
  end
end