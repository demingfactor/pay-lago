require "test_helper"
require "uri"

class Pay::Lago::PaymentMethodTest < ActiveSupport::TestCase
  setup do
    @pay_customer = pay_customers(:lago)
  end

  test "Lago sync returns Pay::PaymentMethod" do
    lago_customer = OpenStruct.new(
      external_id: @pay_customer.processor_id,
      billing_configuration: OpenStruct.new(
        payment_provider: "stripe",
        provider_customer_id: "x"
      )
    )
    pay_payment_method = Pay::Lago::PaymentMethod.sync(lago_customer)
    assert pay_payment_method.is_a?(Pay::PaymentMethod)
    assert pay_payment_method.processor_id == "x"
    assert @pay_customer.default_payment_method == pay_payment_method
  end

  test "PaymentMethod does not push or pull if not default" do
    pay_payment_method = @pay_customer.add_payment_method(:stripe, "test_1234", default: false, sync: false).payment_processor
    assert pay_payment_method.push! == false
    assert pay_payment_method.pull! == false
  end

  test "PaymentMethod can be made default, updating Lago" do
    pay_payment_method = @pay_customer.add_payment_method(:stripe, "test_1234_a", sync: true)
    lago_customer = Pay::Lago.client.customers.get(@pay_customer.pay_external_id)
    assert lago_customer.billing_configuration.provider_customer_id == pay_payment_method.processor_id
  end
end
