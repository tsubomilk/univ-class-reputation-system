class CreateReviews < ActiveRecord::Migration[6.1]
  def change
      create_table :reviews do |t|
        t.integer :reviewId
        t.string :courseId
        t.string :userId
        t.integer :likes
        t.float :dropRate
        t.integer :workload
        t.boolean :groupWork
        t.boolean :hasTests
        t.boolean :hasReports
        t.boolean :hasProgramming
        t.string :targetAudience
        t.text :otherComments
        t.timestamps null: false
      end
  end
end
