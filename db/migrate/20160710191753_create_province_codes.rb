class CreateProvinceCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :province_codes do |t|
      t.text :not_supported, limit: 1
      t.text :province_code, limit: 2
      t.text :province_name, limit: 50
      t.timestamps
    end
  end
end
