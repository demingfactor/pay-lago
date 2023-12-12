module Pay
  module Lago
    module Webhooks
      class CustomerPaymentProviderCreated
        def call(event)
          customer = event.customer
          PaymentMethod.sync(customer)
        end
      end
    end
  end
end
