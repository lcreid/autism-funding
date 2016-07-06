class CreateForms < ActiveRecord::Migration[5.0]
  def change
    create_table :forms do |t|
      t.string :form_name, limit: 100, null: false
      t.string :form_description
      t.string :file_name, limit: 50, null: false
      t.timestamps
    end
  end
end
