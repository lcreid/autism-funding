class DropColumnsFromInvoice < ActiveRecord::Migration[5.0]
  def change
    return
    remove_column :invoices, :service_provider_name, :text
    remove_column :invoices, :agency_name, :text
    remove_column :invoices, :supplier_name, :string
  end
end
