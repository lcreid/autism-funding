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
    assert_equal Date.new(2016, 5, 1)..Date.new(2017, 4, 30),
                 rtp.fiscal_year
  end

  test 'dates are not in one fiscal year' do
    rtp = Cf0925.new
    rtp.funded_person = funded_people(:dob_2003_01_01)
    rtp.service_provider_service_start = Date.new(2008, 1, 31)
    rtp.service_provider_service_end = Date.new(2008, 2, 1)
    rtp.printable?
    assert_equal ['service end date must be in the same fiscal year ' \
                 'as service start date'],
                 rtp.errors[:service_provider_service_end]
  end

  test 'dates are in one fiscal year' do
    rtp = Cf0925.new
    rtp.funded_person = funded_people(:dob_2003_01_01)
    rtp.service_provider_service_start = Date.new(2008, 2, 1)
    rtp.service_provider_service_end = Date.new(2009, 1, 31)
    rtp.printable?
    assert rtp.errors[:service_provider_service_end].empty?,
           -> {
             'Expected no error message. ' \
             "Got #{rtp.errors[:service_provider_service_end]}"
           }
  end

  test 'store numbers' do
    rtp = Cf0925.new(service_provider_service_amount: '2000')
    assert_equal 2_000, rtp.service_provider_service_amount
    rtp.update(service_provider_service_amount: '2000.50')
    assert_equal 2_000.50, rtp.service_provider_service_amount
    rtp.update(service_provider_service_amount: '2,000.50')
    assert_equal 2_000.50, rtp.service_provider_service_amount
  end
end
