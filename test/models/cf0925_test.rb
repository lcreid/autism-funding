require 'test_helper'

class Cf0925Test < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'generation of a PDF' do
    rtp = cf0925s(:one)
    assert rtp.generate_pdf
    assert File.exist?(rtp.pdf_file), "File #{rtp.pdf_file} not found"
  end
end
