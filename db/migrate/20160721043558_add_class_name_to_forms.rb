class AddClassNameToForms < ActiveRecord::Migration[5.0]
  def change
    add_column :forms, :class_name, :string
  end
end
