class CreateForms < ActiveRecord::Migration[5.0]
  def change
    create_table :forms do |t|
      t.references :province_code, foreign_key: true
      t.text :file_name, limit: 50, null: false
      t.text :form_description
      t.text :form_name, limit: 100, null: false
      t.timestamps
    end
  end
end
