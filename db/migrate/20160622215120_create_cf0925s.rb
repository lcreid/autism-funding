class CreateCf0925s < ActiveRecord::Migration[5.0]
  def change
    create_table :cf0925s do |t|
      t.string :agency_name
      t.string :child_dob
      t.string :child_first_name
      t.string :child_last_name
      t.string :child_middle_name
      t.boolean :child_in_care_of_ministry
      t.string :home_phone
      t.decimal :item_cost_1, precision: 7, scale: 2
      t.decimal :item_cost_2, precision: 7, scale: 2
      t.decimal :item_cost_3, precision: 7, scale: 2
      t.string :item_desp_1
      t.string :item_desp_2
      t.string :item_desp_3
      t.string :parent_address
      t.string :parent_city
      t.string :parent_first_name
      t.string :parent_last_name
      t.string :parent_middle_name
      t.string :parent_postal_code
      t.string :payment
      t.string :service_provider_postal_code
      t.string :service_provider_address
      t.string :service_provider_city
      t.string :service_provider_phone
      t.string :service_provider_name
      t.string :service_provider_service_1
      t.string :service_provider_service_2
      t.string :service_provider_service_3
      t.decimal :service_provider_service_amount, precision: 7, scale: 2
      t.date :service_provider_service_end
      t.decimal :service_provider_service_fee, precision: 7, scale: 2
      t.string :service_provider_service_hour
      t.date :service_provider_service_start
      t.string :supplier_address
      t.string :supplier_city
      t.string :supplier_contact_person
      t.string :supplier_name
      t.string :supplier_phone
      t.string :supplier_postal_code
      t.string :work_phone
      t.timestamps
    end
  end
end
