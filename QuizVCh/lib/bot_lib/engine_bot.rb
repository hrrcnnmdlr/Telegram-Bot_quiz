require 'telegram/bot'
require_relative 'app_cofigurator'
require_relative 'database_connector'
require_relative 'message_responder'

module QuizBot
  class EngineBot
    def initialize
      @config = AppConfigurator.instance
      DatabaseConnector.connect!
      @token = YAML.load_file(File.expand_path('../../config/secrets.yml', __dir__))['telegram_bot_token']
    end

    def run
      Telegram::Bot::Client.run(@token) do |bot|
        bot.listen do |message|
          # Визначаємо мову користувача (наприклад, за замовчуванням :ua)
          locale = %i[ua en].include?(message.from.language_code&.to_sym) ? message.from.language_code.to_sym : :ua
          MessageResponder.new(bot, message, locale).respond
        end
      end
    end
  end
end