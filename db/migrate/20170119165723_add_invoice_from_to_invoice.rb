class AddInvoiceFromToInvoice < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :invoice_from, :string
  end
end
