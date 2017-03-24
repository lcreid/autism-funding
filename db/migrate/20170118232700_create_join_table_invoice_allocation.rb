class CreateJoinTableInvoiceAllocation < ActiveRecord::Migration[5.0]
  def change
    create_table 'invoice_allocations', id: false do |t|
      t.belongs_to :cf0925
      t.belongs_to :invoice
      t.decimal :amount, precision: 7, scale: 2
      t.index [:cf0925_id, :invoice_id]
      t.index [:invoice_id, :cf0925_id]
    end
  end
end
