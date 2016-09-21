require 'test_helper'

class Cf0925Test < ActiveSupport::TestCase
  test 'generation of a PDF' do
    unless ENV['TEST_PDF_GENERATION']
      skip 'Skipping PDF generation. To include: `export TEST_PDF_GENERATION=1`'
    end
    rtp = cf0925s(:one)
    assert rtp.generate_pdf
    assert File.exist?(rtp.pdf_output_file), "File #{rtp.pdf_output_file} not found"
  end

  test 'not printable' do
    rtp = cf0925s(:minimum_printable)
    rtp.parent_last_name = nil
    assert !rtp.printable?, 'should be not printable'
  end

  test 'fiscal year' do
    rtp = cf0925s(:one)
    assert_equal Date.new(2016, 5, 1)...Date.new(2017, 5, 1),
                 rtp.fiscal_year.range
  end
end
