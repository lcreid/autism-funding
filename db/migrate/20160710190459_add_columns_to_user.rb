class AddColumnsToUser < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.text :name_first, limit: 50
      t.text :name_last, limit: 50
      t.text :name_middle, limit: 50
      t.text :role, limit: 15
    end
  end
end
