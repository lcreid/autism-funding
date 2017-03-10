require 'test_helper'

class SpoofedUrls < ActionDispatch::IntegrationTest
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
                                  email: 'b@example.com',
                                  name_last: 'stolen'
                                },
                                name_last: 'stolen')
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

  test "user can't get other users' RTPs" do
    # In dev and test, we get the exception here.
    # In production, this exception will cause the 404 page to be displayed.
    assert_raises ActiveRecord::RecordNotFound do
      get cf0925_path(@other_rtp), params: { format: :pdf }
    end
  end

  test "user can't edit other users' RTPs" do
    assert_raises ActiveRecord::RecordNotFound do
      get edit_cf0925_path(@other_rtp)
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

  test "user can't create RTPs for others' children" do
    assert_raises ActiveRecord::RecordNotFound do
      get new_funded_person_cf0925_path(@other_child)
    end
  end

  test "user can't delete other users' RTPs" do
    assert_raises ActiveRecord::RecordNotFound do
      delete cf0925_path(@other_rtp)
    end
  end
end
