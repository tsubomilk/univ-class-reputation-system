class AddListIdToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :list_id, :integer, default: 1
  end
end
