class CreateFundedPeople < ActiveRecord::Migration[5.0]
  def change
    create_table :funded_people do |t|
      t.references :user, foreign_key: true
      t.date :birthdate
      t.text :name_first, limit: 50
      t.text :name_last, limit: 50
      t.text :name_middle, limit: 50
      t.timestamps
    end
  end
end
