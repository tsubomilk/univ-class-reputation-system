class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.references :user
      t.string :title
      t.timestamps null: false
    end
  end
end
