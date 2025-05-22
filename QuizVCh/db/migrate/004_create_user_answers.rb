class CreateUserAnswers < ActiveRecord::Migration[4.2]
  def change
    create_table :user_answers, force: true do |t|
      t.integer :user_id
      t.integer :question_id
      t.string  :answer
      t.boolean :correct
      t.timestamps
    end
  end
end