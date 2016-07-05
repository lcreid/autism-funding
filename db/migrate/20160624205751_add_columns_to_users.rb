class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.belongs_to :province_code, index: true
      t.string :role, limit: 15
      t.string :address_line_1, limit: 40
      t.string :address_line_2, limit: 40
      t.string :city, limit: 40
      t.string :postal_code, limit: 6

      t.string :name_first, limit: 50
      t.string :name_last, limit: 50
      t.string :name_middle, limit: 50

      t.string :phone_number, limit: 10
      t.string :phone_extension, limit: 10

      t.string :work_phone_number, limit: 10
      t.string :work_phone_extension, limit: 10
    end
  end
end
