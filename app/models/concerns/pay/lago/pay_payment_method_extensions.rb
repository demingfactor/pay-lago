module Pay
  module Lago
    module PayPaymentMethodExtensions
      extend ActiveSupport::Concern

      included do
        scope :with_provider, ->(provider) { where("pay_payment_methods.data->>'payment_provider' = ?", provider) }
      end

      def provider
        data["payment_provider"].to_sym
      rescue
        nil
      end

      class_methods do
        def find_by_lago_provider_and_id(provider, provider_id)
          with_provider(provider).find_by_processor_and_id(:lago, provider_id)
        end
      end
    end
  end
end