class CreateProvinceCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :province_codes do |t|
      t.string :province_code, limit: 2
      t.string :not_supported, limit: 1

      t.timestamps
    end
  end
end
