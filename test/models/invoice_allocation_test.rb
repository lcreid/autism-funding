require "test_helper"
require "helpers/status_test_helpers"

class InvoiceAllocationTest < ActiveSupport::TestCase
  include StatusTestHelpers

  # Issue #72 tests
  test "decrease part A decreases invoice allocation" do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child,
      SUPPLIER_ATTRS
      .merge(
        service_provider_service_amount: 750))

    child.save!
    invoice = child.invoices.create(invoice_amount: 750,
                                    invoice_date: "2017-01-31",
                                    service_end: "2017-01-31",
                                    service_start: "2017-01-01",
                                    invoice_from: "Pay Me Agency")

    assert invoice.connect(rtp, "ServiceProvider", 750)

    assert_status(child,
      "2016-2017",
      spent_out_of_pocket: 0,
      spent_funds: 750)

    rtp.service_provider_service_amount = 500
    rtp.save!

    assert_status(child,
      "2016-2017",
      spent_out_of_pocket: 250,
      spent_funds: 500)
  end

  test "decrease part B decreases invoice allocation" do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child,
      SUPPLIER_ATTRS.merge(item_cost_2: 0))

    child.save!
    invoice = child.invoices.create(invoice_amount: 1_000,
                                    invoice_date: "2016-12-30",
                                    invoice_from: "Supplier Name")

    assert invoice.connect(rtp, "Supplier", 600)

    assert_status(child,
      "2016-2017",
      spent_out_of_pocket: 400,
      spent_funds: 600)

    rtp.item_cost_1 = 500
    rtp.save!

    assert_status(child,
      "2016-2017",
      spent_out_of_pocket: 500,
      spent_funds: 500)
  end

  test "decrease part A where there are two invoice allocations " \
    "reduces last to 0 " \
    "and decreases second-last" do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)

    child.save!
    invoice = child.invoices.create(invoice_amount: 750,
                                    invoice_date: "2017-01-31",
                                    service_end: "2017-01-31",
                                    service_start: "2017-01-01",
                                    invoice_from: "Pay Me Agency")
    assert(i1 = invoice.connect(rtp, "ServiceProvider", 750))

    invoice = child.invoices.create(invoice_amount: 500,
                                    invoice_date: "2016-12-31",
                                    service_end: "2016-12-31",
                                    service_start: "2016-12-01",
                                    invoice_from: "Pay Me Agency")
    assert(i2 = invoice.connect(rtp, "ServiceProvider", 500))

    assert_status(child,
      "2016-2017",
      spent_out_of_pocket: 0,
      spent_funds: 1_250)

    rtp.service_provider_service_amount = 500
    rtp.save!

    assert_equal 0, i1.reload.amount
    assert_equal 500, i2.reload.amount

    assert_status(child,
      "2016-2017",
      spent_out_of_pocket: 750,
      spent_funds: 500)
  end

  test "RTP with both parts and invoice allocated to both parts " \
    "reduce part B reduces the part B allocation" do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child,
      SUPPLIER_ATTRS
       .merge(supplier_name: "Pay Me Agency",
              service_provider_service_amount: 750))

    child.save!
    invoice = child.invoices.create(invoice_amount: 1_000,
                                    invoice_date: "2016-12-30",
                                    invoice_from: "Pay Me Agency")
    assert invoice.connect(rtp, "ServiceProvider", 1_000)

    invoice = child.invoices.create(invoice_amount: 1_000,
                                    invoice_date: "2016-12-30",
                                    invoice_from: "Pay Me Agency")
    assert invoice.connect(rtp, "Supplier", 750)

    assert_status(child,
      "2016-2017",
      spent_out_of_pocket: 250,
      spent_funds: 1_750)

    rtp.item_cost_2 = 0
    rtp.save!

    assert_status(child,
      "2016-2017",
      spent_out_of_pocket: 400,
      spent_funds: 1_600)
  end

  test "One invoice, allocated to two RTPs " \
    "reduce part A of first RTP " \
    "reduces the allocation of the right invoice" do
    child = set_up_child
    rtp_a = set_up_provider_agency_rtp(child, service_provider_service_amount: 500)
    rtp_b = set_up_provider_agency_rtp(child,
      service_provider_service_amount: 500,
      service_provider_service_end: "2017-04-30",
      service_provider_service_start: "2017-04-01")

    child.save!
    i = child.invoices.create(invoice_amount: 1_100,
                              invoice_date: "2017-05-01",
                              service_end: "2017-04-30",
                              service_start: "2017-01-01",
                              invoice_from: "Pay Me Agency")
    i.connect(rtp_a, "ServiceProvider", 500)
    i.connect(rtp_b, "ServiceProvider", 500)

    assert_status(child, "2016-2017",
      spent_out_of_pocket: 100,
      spent_funds: 1_000)

    rtp_a.service_provider_service_amount = 100
    rtp_a.save!
    assert_status(child, "2016-2017",
      spent_out_of_pocket: 500,
      spent_funds: 600)
  end
  # End Issue #72 tests
end
