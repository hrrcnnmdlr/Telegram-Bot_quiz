require 'i18n'
require 'logger'
require_relative '../../models/user'
require_relative '../../models/user_answer'
require_relative '../../models/result'
require_relative '../../models/quiz_test'

I18n.load_path << File.expand_path('../../../config/locales.yml', __dir__)
I18n.default_locale = :ua

module QuizBot
  class MessageResponder
    @@user_states ||= {}

    def initialize(bot, message, locale = :ua)
      @bot = bot
      @message = message
      @locale = locale
    end

    def respond
      user_id = @message.from.id
      puts "[DEBUG] message.text: #{@message.text.inspect}"
      @@user_states[user_id] ||= { state: :idle, current: 0, correct: 0 }

      if @message.text == '/start'
        @@user_states[user_id] = { state: :waiting_for_test, current: 0, correct: 0, started_at: Time.now }
        button = I18n.t(:start_test, locale: @locale)
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard: [[{ text: button }]],
          one_time_keyboard: true,
          resize_keyboard: true
        )
        @bot.api.send_message(chat_id: @message.chat.id, text: I18n.t(:greeting_message, locale: @locale), reply_markup: markup)
      elsif @message.text == I18n.t(:start_test, locale: @locale) && @@user_states[user_id][:state] == :waiting_for_test
        questions = QuizVCh::QuestionData.new.collection.shuffle
        @@user_states[user_id][:questions] = questions

        user = User.find_or_create_by(uid: user_id) { |u| u.username = @message.from.first_name }
        quiz_test = QuizTest.create(user: user, status: 1, started_at: Time.now)
        # Створення writer для протоколу
        filename = "log/#{user.username}_#{Time.now.strftime('%Y%m%d_%H%M%S')}.log"
        writer = Logger.new(filename)
        @@user_states[user_id][:quiz_test_id] = quiz_test.id
        @@user_states[user_id][:writer] = writer
        @@user_states[user_id][:correct] = 0
        @@user_states[user_id][:incorrect] = 0
        @@user_states[user_id][:state] = :testing
        send_question(user_id)
      elsif @@user_states[user_id][:state] == :testing
        process_answer(user_id)
      elsif @message.text == "Статистика" && @@user_states[user_id][:state] == :finished
        user = User.find_by(uid: user_id)
        last_test = user.quiz_tests.where.not(finished_at: nil).order(finished_at: :desc).first
        if last_test
          stat_text = "Ваша статистика:\n" \
                      "Правильних: #{last_test.correct_answers}\n" \
                      "Неправильних: #{last_test.incorrect_answers}\n" \
                      "Відсоток: #{last_test.percent}%"
        else
          stat_text = "Статистика відсутня."
        end
        @bot.api.send_message(chat_id: @message.chat.id, text: stat_text,
          reply_markup: Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true))
        @@user_states.delete(user_id)
      elsif @message.text == '/stop'
        @bot.api.send_message(chat_id: @message.chat.id, text: I18n.t(:farewell_message, locale: @locale))
        @@user_states.delete(user_id)
      else
        @bot.api.send_message(chat_id: @message.chat.id, text: I18n.t(:unknown_command, locale: @locale))
      end
    end

    def send_question(user_id)
      state = @@user_states[user_id]
      questions = @@user_states[user_id][:questions]
      if state[:current] < questions.size
        q = questions[state[:current]]
        answers = q.original_answers.map(&:to_s)
        keyboard = answers.map { |a| [{ text: a }] }
        user_name = @message.from.first_name || "Користувач"
        question_text = "#{user_name}, наступне питання:\n#{q.question_body}\n"
        answers.each_with_index do |ans, idx|
          question_text += "#{idx + 1}. #{ans}\n"
        end
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard: keyboard,
          one_time_keyboard: true,
          resize_keyboard: true
        )
        @bot.api.send_message(chat_id: @message.chat.id, text: question_text, reply_markup: markup)
      else
        # Зберігаємо результат у таблицю results
        user = User.find_by(uid: user_id)
        Result.create(
          user_id: user.id,
          score: state[:correct],
          started_at: state[:started_at],
          finished_at: Time.now
        )
        # Логування завершення тесту
        logger = Logger.new('log/debug.log')
        logger.info "User #{user_id} finished test with score #{state[:correct]}/#{questions.size}"

        @bot.api.send_message(
          chat_id: @message.chat.id,
          text: I18n.t(:test_finished, locale: @locale, correct: state[:correct], total: questions.size),
          reply_markup: Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
        )
        @@user_states.delete(user_id)
      end
    end

    def process_answer(user_id)
      state = @@user_states[user_id]
      questions = @@user_states[user_id][:questions]
      q = questions[state[:current]]
      user_answer = @message.text.strip
      correct_answer = q.question_correct_answer.strip
      correct = user_answer.downcase == correct_answer.downcase

      user = User.find_or_create_by(uid: user_id) { |u| u.username = @message.from.first_name }
      db_question = Question.find_by(body: q.question_body)
      quiz_test = QuizTest.find_by(id: state[:quiz_test_id])

      UserAnswer.create(
        user_id: user.id,
        question_id: db_question&.id,
        answer: user_answer,
        correct: correct,
        created_at: Time.now
      )

      writer = state[:writer]
      writer.info "Q: #{q.question_body}"
      writer.info "A: #{user_answer} (#{correct ? I18n.t(:right, locale: :en) : I18n.t(:wrong, locale: :en)})"

      if correct
        state[:correct] += 1
        @bot.api.send_message(chat_id: @message.chat.id, text: I18n.t(:right, locale: @locale))
      else
        state[:incorrect] += 1
        @bot.api.send_message(chat_id: @message.chat.id, text: I18n.t(:wrong, locale: @locale))
      end

      state[:current] += 1

      if state[:current] < questions.size
        send_question(user_id)
      else
        percent = (state[:correct].to_f / questions.size * 100).round(2)
        quiz_test.update(
          status: 2,
          correct_answers: state[:correct],
          incorrect_answers: state[:incorrect],
          percent: percent,
          finished_at: Time.now
        )
        writer.info "Тест завершено. Правильних: #{state[:correct]}, Неправильних: #{state[:incorrect]}, Відсоток: #{percent}%"
        writer.info "Test finished. Correct: #{state[:correct]}, Incorrect: #{state[:incorrect]}, Percent: #{percent}%"
        writer.close

        # Локалізована кнопка "Статистика"
        stat_button = I18n.t(:show_stats, locale: @locale)
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard: [[{ text: stat_button }]],
          one_time_keyboard: true,
          resize_keyboard: true
        )

        # Локалізоване повідомлення про завершення тесту
        finish_text = I18n.t(
          :test_finished_stats,
          locale: @locale,
          correct: state[:correct],
          incorrect: state[:incorrect],
          percent: percent
        )

        @bot.api.send_message(
          chat_id: @message.chat.id,
          text: finish_text,
          reply_markup: markup
        )
        @@user_states[user_id][:state] = :finished
      end
    end
  end
end