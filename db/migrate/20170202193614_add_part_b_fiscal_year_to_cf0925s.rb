class AddPartBFiscalYearToCf0925s < ActiveRecord::Migration[5.0]
  def change
    add_column :cf0925s, :part_b_fiscal_year, :string
  end
end
