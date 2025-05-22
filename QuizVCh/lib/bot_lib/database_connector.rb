require 'active_record'
require 'yaml'

module QuizBot
  class DatabaseConnector
    def self.connect!(env = 'development')
      config_path = File.expand_path('../../config/database.yml', __dir__)
      db_config = YAML.load_file(config_path)
      ActiveRecord::Base.establish_connection(db_config)
    end
  end
end