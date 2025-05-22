class CreateResults < ActiveRecord::Migration[4.2]
  def change
    create_table :results, force: true do |t|
      t.references :user, foreign_key: true
      t.integer    :score
      t.datetime   :started_at
      t.datetime   :finished_at
      t.timestamps
    end
  end
end