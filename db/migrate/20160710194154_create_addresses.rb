class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.references :province_code, foreign_key: true
      t.references :user, foreign_key: true
      t.text :address_line_1, limit: 40
      t.text :address_line_2, limit: 40
      t.text :city, limit: 40
      t.text :postal_code, limit: 6
      t.timestamps
    end
  end
end
