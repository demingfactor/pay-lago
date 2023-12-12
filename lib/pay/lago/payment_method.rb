module Pay
  module Lago
    class PaymentMethod
      VALID_PROVIDERS = %i[stripe adyen gocardless]
      attr_reader :pay_payment_method

      delegate :customer, :processor_id, to: :pay_payment_method

      def self.valid_provider?(provider)
        VALID_PROVIDERS.include?(provider.to_s.to_sym)
      end

      # Lago doesn't provide PaymentMethod IDs, so we have to lookup via the Customer.
      # The most recently synced payment method is *always* the default.
      def self.sync(lago_customer)
        pay_customer = Pay::Customer.find_by(processor_id: lago_customer.external_id)
        if pay_customer.blank?
          Rails.logger.debug "Pay::Customer #{lago_customer.external_id} is not in the database while syncing Payment Method
          #{lago_customer.provider_customer_id}"
          return
        end

        payment_data = lago_customer.billing_configuration
        provider_id = payment_data.provider_customer_id

        payment_method = pay_customer.payment_methods.find_by(processor_id: provider_id)
        payment_method ||= pay_customer.build_default_payment_method

        payment_method_attr = {
          processor_id: provider_id,
          type: "card",
          data: Lago.openstruct_to_h(payment_data)
        }

        payment_method.update!(payment_method_attr)
        payment_method.make_default!
        
        payment_method
      rescue ::Lago::Api::HttpError => e
        raise Pay::Lago::Error, e
      end

      def initialize(pay_payment_method)
        @pay_payment_method = pay_payment_method
      end

      def pull!
        return false unless pay_payment_method.default?
        customer.pull!
        pay_payment_method.update!(data: customer.data["billing_configuration"])
      end

      def push!
        return false unless pay_payment_method.default?
        update_customer!
        customer.push!
      end

      def make_default!
        update_customer!
      end

      def detach!
        customer.clear_payment_method!
      end

      private

      def update_customer!
        data = (customer.data || {}).merge("billing_configuration": pay_payment_method.data)
        customer.update!(data: data)
      end
    end
  end
end
