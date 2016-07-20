class CreatePhoneNumberTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :phone_number_types do |t|
      t.text :phone_type
      t.timestamps
    end
  end
end
