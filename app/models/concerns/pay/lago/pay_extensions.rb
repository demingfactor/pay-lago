module Pay
  module Lago
    module PayExtensions
      extend ActiveSupport::Concern

      included do
        scope :lago, -> { joins(:customer).where(pay_customers: {processor: "lago"}) }
      end

      def lago?
        customer.processor == "lago"
      end
    end
  end
end