require "test_helper"

class SpoofedUrlsTest < ActionDispatch::IntegrationTest
  include TestSessionHelpers

  def setup
    @logged_in_child = set_up_child
    @logged_in_user = @logged_in_child.user
    @logged_in_user.save!
    @logged_in_rtp = set_up_provider_agency_rtp(@logged_in_child)
    @logged_in_rtp.save!
    @logged_in_invoice = @logged_in_child
                         .invoices
                         .create(invoice_from: @logged_in_rtp.agency_name,
                                 invoice_amount: 200,
                                 service_start:
                                  @logged_in_rtp.service_provider_service_start,
                                 service_end:
                                  @logged_in_rtp.service_provider_service_end)

    @other_child = set_up_child({
                                  email: "b@example.com",
                                  name_last: "stolen"
                                },
      name_last: "stolen")
    @other_user = @other_child.user
    @other_user.save!
    @other_rtp = set_up_provider_agency_rtp(@other_child)
    @other_rtp.save!
    @other_invoice = @other_child
                     .invoices
                     .create(invoice_from: @other_rtp.agency_name,
                             invoice_amount: 300,
                             service_start:
                              @other_rtp.service_provider_service_start,
                             service_end:
                              @other_rtp.service_provider_service_end)

    log_in(@logged_in_user)
  end

  test "user can't get other users' RTP list" do
    # In dev and test, we get the exception here.
    # In production, this exception will cause the 404 page to be displayed.
    assert_raises ActiveRecord::RecordNotFound do
      get funded_person_cf0925s_path(@other_child)
    end
  end

  test "user can't get other users' RTPs (PDF)" do
    # In dev and test, we get the exception here.
    # In production, this exception will cause the 404 page to be displayed.
    assert_raises ActiveRecord::RecordNotFound do
      get cf0925_path(@other_rtp), params: { format: :pdf }
    end
  end

  test "user can't bring up new Cf0925 form with another child" do
    assert_raises ActiveRecord::RecordNotFound do
      get new_funded_person_cf0925_path(@other_child)
    end
  end

  test "user can't edit other users' RTPs" do
    assert_raises ActiveRecord::RecordNotFound do
      get edit_cf0925_path(@other_rtp)
    end
  end

  test "user can't create RTPs for others' children" do
    assert_raises ActiveRecord::RecordNotFound do
      post funded_person_cf0925s_path(@other_child),
        params: {
          cf0925: @other_rtp.attributes.merge(
            funded_person_attributes:
             @other_child.attributes.merge(
               user_attributes:
                 @logged_in_user.attributes))
        }
    end
  end

  test "user can't update other users' RTPs" do
    assert_raises ActiveRecord::RecordNotFound do
      put cf0925_path(@other_rtp),
        params: {
          cf0925: @other_rtp.attributes.merge(
            funded_person_attributes:
             @other_child.attributes.merge(
               user_attributes:
                 @logged_in_user.attributes))
        }
    end
  end

  test "user can't delete other users' RTPs" do
    assert_raises ActiveRecord::RecordNotFound do
      delete cf0925_path(@other_rtp)
    end
  end

  test "user can't get other users' invoice list" do
    # In dev and test, we get the exception here.
    # In production, this exception will cause the 404 page to be displayed.
    assert_raises ActiveRecord::RecordNotFound do
      get funded_person_invoices_path(@other_child)
    end
  end

  test "user can't bring up new invoice form with another child" do
    assert_raises ActiveRecord::RecordNotFound do
      get new_funded_person_invoice_path(@other_child)
    end
  end

  test "user can't edit other users' invoices" do
    assert_raises ActiveRecord::RecordNotFound do
      get edit_invoice_path(@other_invoice)
    end
  end

  test "user can't create invoices for others' children" do
    assert_raises ActiveRecord::RecordNotFound do
      post funded_person_invoices_path(@other_child),
        params: {
          invoice: @other_invoice.attributes
        }
    end
  end

  test "user can't update other users' invoices" do
    assert_raises ActiveRecord::RecordNotFound do
      put invoice_path(@other_invoice),
        params: {
          invoice: @other_invoice.attributes
        }
    end
  end

  test "user can't delete other users' invoices" do
    assert_raises ActiveRecord::RecordNotFound do
      delete invoice_path(@other_invoice)
    end
  end

  test "user can't retrieve other users' RTPs with existing invoice" do
    assert_raises ActiveRecord::RecordNotFound do
      get invoices_rtps_path,
        params: @other_invoice.attributes.except("id"), xhr: true
    end
  end

  test "user can't retrieve other users' RTPs with no existing invoice" do
    assert_raises ActiveRecord::RecordNotFound do
      get invoices_rtps_path, params: @other_invoice.attributes, xhr: true
    end
  end
end
