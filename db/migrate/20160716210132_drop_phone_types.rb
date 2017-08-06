class DropPhoneTypes < ActiveRecord::Migration[5.0]
  def up
    drop_table :phone_number_types
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
