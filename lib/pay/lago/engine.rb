module Pay
  module Lago
    class Engine < ::Rails::Engine
      engine_name "pay_lago"

      initializer "pay_lago.processors", after: "pay.processors" do |app|
        ActiveSupport.on_load(:active_record) do
          include Pay::Lago::Attributes
        end
      end

      config.before_initialize do
        Pay::Lago.configure_webhooks if Pay::Lago.enabled?
      end

      config.to_prepare do
        # Include Concerns
        Pay::Customer.include Pay::Lago::PayCustomerExtensions
        Pay::Charge.include Pay::Lago::PayExtensions
        Pay::Subscription.include Pay::Lago::PayExtensions
        Pay::PaymentMethod.include Pay::Lago::PayPaymentMethodExtensions

        # Prepend Pay::Lago extensions
        Pay::Webhook.prepend Pay::Lago::WebhookExtensions
      end
    end
  end
end