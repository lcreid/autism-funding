require_relative '20170119010352_populate_invoice_allocation.rb'

class PopulateInvoiceAllocations < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        revert PopulateInvoiceAllocation

        say_with_time 'Populating invoice_allocations' do
          Invoice.select(&:cf0925).each do |invoice|
            type = if invoice.supplier_name == invoice.cf0925.supplier_name
                     'Supplier'
                   else
                     'ServiceProvider'
                   end
            InvoiceAllocation.create!(cf0925: invoice.cf0925,
                                      invoice: invoice,
                                      cf0925_type: type)
          end.count
        end
      end

      dir.down do
        say_with_time 'Deleting data in invoice_allocations' do
          # You have to do the raw sql because your can't directly delete
          # a join table entry, because it doesn't have a single-column
          # primary key.
          execute('truncate table invoice_allocations;')
          # InvoiceAllocation.all.each do |ci|
          #   puts ci.inspect
          #   ci.destroy!
          # end
        end
      end
    end
  end
end
