class AddProvinceNameToPRovinceCode < ActiveRecord::Migration[5.0]
  def change
    add_column :province_codes, :province_name, :text, limit: 25
  end
end
