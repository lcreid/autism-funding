class DropPhoneTypes < ActiveRecord::Migration[5.0]
  def up
        drop_table :phone_number_types
  end
  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
