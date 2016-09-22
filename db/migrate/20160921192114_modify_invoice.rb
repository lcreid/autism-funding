class ModifyInvoice < ActiveRecord::Migration[5.0]
  def change
    change_table :invoices do |t|
#        t.remove :cf0925_id
        t.references :funded_person, foreign_key: true
        t.rename  :supplier_reference, :invoice_reference
        t.text :agency_name
        t.text :service_provider_name
    end
  end
end
