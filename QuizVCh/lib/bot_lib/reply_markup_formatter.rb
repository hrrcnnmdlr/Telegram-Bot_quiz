require 'telegram/bot'

module QuizBot
  class ReplyMarkupFormatter
    # Формує клавіатуру для відповідей (наприклад, для 3 варіантів)
    def self.format_answers(answers)
      buttons = answers.map { |answer| Telegram::Bot::Types::KeyboardButton.new(text: answer) }
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: buttons.each_slice(2).to_a,
        one_time_keyboard: true,
        resize_keyboard: true
      )
    end

    # Прибирає клавіатуру
    def self.remove_keyboard
      Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    end
  end
end