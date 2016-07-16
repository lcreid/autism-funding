class AddPhoneTypeToPhoneNumbers < ActiveRecord::Migration[5.0]
  def change
    change_table :phone_numbers do |t|
      t.remove :phone_number_type
      t.text :phone_type, limit: 25
    end
  end
end
