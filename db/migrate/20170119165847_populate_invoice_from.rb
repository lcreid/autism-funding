class PopulateInvoiceFrom < ActiveRecord::Migration[5.0]
  def change
    separator = '/'

    reversible do |dir|
      dir.up do
        say_with_time 'Populating invoice_from' do
          Invoice.all.each do |invoice|
            ary = [invoice.service_provider_name,
                   invoice.agency_name,
                   invoice.supplier_name]
            ary.pop while !ary.empty? && ary.last.nil?
            invoice.update!(invoice_from: ary.join(separator))
          end.count
        end
      end

      dir.down do
        say_with_time 'Populating original attributes from invoice_from' do
          Invoice.all.each do |invoice|
            ary = invoice.invoice_from.split(separator, 3)
            invoice.update!(service_provider_name: ary[0],
                            agency_name: ary[1],
                            supplier_name: ary[2])
          end.count
        end
      end
    end
  end
end
