require 'test_helper'

class Cf0925Test < ActiveSupport::TestCase
  test 'generation of a PDF' do
    unless ENV['TEST_PDF_GENERATION']
      skip 'Skipping PDF generation. To include: `export TEST_PDF_GENERATION=1`'
    end
    rtp = cf0925s(:one)
    assert rtp.generate_pdf
    assert File.exist?(rtp.pdf_file), "File #{rtp.pdf_file} not found"
  end
end
