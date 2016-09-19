class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.references :cf0925, foreign_key: true
      t.decimal :invoice_amount, precision: 7, scale: 2
      t.date :invoice_date
      t.string :notes
      t.date :service_end
      t.date :service_start
      t.string :supplier_name
      t.string :supplier_reference
      t.timestamps
    end
  end
end
