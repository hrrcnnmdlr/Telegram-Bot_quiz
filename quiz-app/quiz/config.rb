require_relative 'quiz'

QuizVCh::Quiz.instance.config do |c|
  c.yaml_dir = "quiz/yml"
  c.answers_dir = "quiz/answers"
  c.in_ext = "yml"
end