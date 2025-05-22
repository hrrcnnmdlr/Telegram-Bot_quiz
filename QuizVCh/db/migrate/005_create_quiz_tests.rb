class CreateQuizTests < ActiveRecord::Migration[4.2]
  def change
    create_table :quiz_tests, force: true do |t|
      t.integer :current_question, default: 0
      t.integer :status, default: 0
      t.integer :correct_answers, default: 0
      t.integer :incorrect_answers, default: 0
      t.decimal :percent, precision: 10, scale: 2, default: 0
      t.references :user, foreign_key: true
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end
  end
end