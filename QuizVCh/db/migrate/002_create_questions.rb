class CreateQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :questions, force: true do |t|
      t.string  :body
      t.string  :correct_answer
      t.text    :answers # зберігаємо як YAML або JSON
      t.timestamps
    end
  end
end