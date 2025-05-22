require_relative 'quiz'

QuizVCh::Quiz.instance.config do |quiz|
  quiz.yaml_dir = File.expand_path('../../config/quiz_yml', __dir__)
  quiz.answers_dir = File.expand_path('../../quiz_answers', __dir__)
  quiz.log_dir = File.expand_path('../../log', __dir__)
end