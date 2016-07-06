class ChangeProvinceCode < ActiveRecord::Migration[5.0]
  def change
    change_table :province_codes do |t|
      t.rename :province_code, :prov_code
    end

  end
end
