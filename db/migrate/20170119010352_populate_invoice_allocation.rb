class PopulateInvoiceAllocation < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        say_with_time 'Populating invoice_allocations' do
          Invoice.select(&:cf0925).each do |invoice|
            InvoiceAllocation.create!(cf0925: invoice.cf0925,
                                      invoice: invoice)
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
