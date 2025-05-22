module QuizBot
  class MessageSender
    def initialize(bot, chat_id)
      @bot = bot
      @chat_id = chat_id
    end

    def send_message(text, reply_markup: nil)
      @bot.api.send_message(chat_id: @chat_id, text: text, reply_markup: reply_markup)
    end

    def send_question(question, answers, locale: :ua)
      buttons = answers.map { |answer| Telegram::Bot::Types::KeyboardButton.new(text: answer) }
      markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: buttons.each_slice(2).to_a, one_time_keyboard: true)
      send_message(question, reply_markup: markup)
    end

    def remove_keyboard(text)
      markup = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      send_message(text, reply_markup: markup)
    end
  end
end