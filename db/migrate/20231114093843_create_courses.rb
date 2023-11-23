class CreateCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :courses do |t|
      t.integer :class_id
      t.string :className
      t.string :teacher
      t.integer :grade
      t.string :week
      t.string :time
    end
  end
end
