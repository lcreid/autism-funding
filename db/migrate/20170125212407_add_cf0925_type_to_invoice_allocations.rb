class AddCf0925TypeToInvoiceAllocations < ActiveRecord::Migration[5.0]
  def change
    add_column :invoice_allocations, :cf0925_type, :string
  end
end
