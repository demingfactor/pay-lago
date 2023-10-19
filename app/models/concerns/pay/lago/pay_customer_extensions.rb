module Pay
  module Lago
    module PayCustomerExtensions
      extend ActiveSupport::Concern

      included do
        scope :lago, -> { where(processor: "lago") }
      end

      def lago?
        processor == "lago"
      end
    end
  end
end