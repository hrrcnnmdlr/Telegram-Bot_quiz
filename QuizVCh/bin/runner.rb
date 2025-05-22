#!/usr/bin/env ruby

# Завантаження всіх бібліотек
require_relative "../lib/load_libraries"

QuizVCh::Quiz.instance.config do |quiz|
  quiz.yaml_dir = "../config/quiz_yml"
  quiz.answers_dir = "../quiz_answers"
  quiz.log_dir = "../log"
end

# engine = QuizVCh::Engine.new
# engine.run

# Якщо у вас є модуль QuizBot, використовуйте його так:
QuizBot::AppConfigurator.instance.config do |quiz_bot|
  quiz_bot.yaml_dir = "../config/quiz_yml"
  quiz_bot.log_dir = "../log"
end

QuizBot::EngineBot.new.run

require 'active_record'
require 'yaml'
require 'logger'

# Підключення до бази даних (PostgreSQL)
db_config = YAML.load_file(File.expand_path('../config/database.yml', __dir__))
ActiveRecord::Base.establish_connection(db_config)

# Логування всіх SQL-запитів у log/debug.log
ActiveRecord::Base.logger = Logger.new(File.expand_path('../log/debug.log', __dir__))