class CreateFundedPeople < ActiveRecord::Migration[5.0]
  def change
    create_table :funded_people do |t|
      t.belongs_to :user, index: true
      t.date :birthdate
      t.string :name_first, limit: 50
      t.string :name_last, limit: 50
      t.string :name_middle, limit: 50
      t.timestamps
    end
  end
end
