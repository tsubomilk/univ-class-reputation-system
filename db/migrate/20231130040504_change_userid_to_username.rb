class ChangeUseridToUsername < ActiveRecord::Migration[6.1]
  def change
    rename_column :reviews, :userId, :userName
  end
end
