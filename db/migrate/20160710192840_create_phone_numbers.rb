class CreatePhoneNumbers < ActiveRecord::Migration[5.0]
  def change
    create_table :phone_numbers do |t|
      t.references :phone_number_type, foreign_key: true
      t.references :user, foreign_key: true
      t.text :phone_extension, limit: 10
      t.text :phone_number, limit: 10
      t.timestamps
    end
  end
end
