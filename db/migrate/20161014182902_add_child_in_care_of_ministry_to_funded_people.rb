class AddChildInCareOfMinistryToFundedPeople < ActiveRecord::Migration[5.0]
  def change
    change_table :funded_people do |t|
      t.boolean :child_in_care_of_ministry
    end
  end
end
