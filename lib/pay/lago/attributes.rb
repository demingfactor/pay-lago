module Pay
  module Lago
    module Attributes
      extend ActiveSupport::Concern

      module CustomerExtension
        extend ActiveSupport::Concern

        included do
          cattr_accessor :pay_lago_customer_attributes
        end
      end

      class_methods do
        def pay_customer(options = {})
          include CustomerExtension

          self.pay_lago_customer_attributes = options[:lago_attributes]
          super
        end
      end
    end
  end
end