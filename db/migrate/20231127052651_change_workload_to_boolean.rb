class ChangeWorkloadToBoolean < ActiveRecord::Migration[6.1]
  def up
    # workloadが0ならfalse、それ以外（通常は1）ならtrueに変換する
    change_column :reviews, :workload, 'boolean USING CASE WHEN workload = 0 THEN FALSE ELSE TRUE END'
  end

  def down
    # booleanからintegerへの変換では、trueは1、falseは0に戻す
    change_column :reviews, :workload, 'integer USING CASE WHEN workload THEN 1 ELSE 0 END'
  end
end
