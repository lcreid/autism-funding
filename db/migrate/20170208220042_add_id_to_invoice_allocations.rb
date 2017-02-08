class AddIdToInvoiceAllocations < ActiveRecord::Migration[5.0]
  def change
    add_column :invoice_allocations, :id, :primary_key
  end
end
