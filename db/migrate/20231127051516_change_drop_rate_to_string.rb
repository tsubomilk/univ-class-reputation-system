class ChangeDropRateToString < ActiveRecord::Migration[6.1]
  def change
    change_column :reviews, :dropRate, :string
  end
end
