class AddFormToCf0925s < ActiveRecord::Migration[5.0]
  def change
    add_reference :cf0925s, :form, foreign_key: true
  end
end
