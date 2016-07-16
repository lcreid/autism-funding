class CreateForms < ActiveRecord::Migration[5.0]
  def change
    create_table :forms do |t|
      t.references :province, foreign_key: true
      t.string :form_name
      t.text :form_description
      t.string :file_name

      t.timestamps
    end
  end
end
