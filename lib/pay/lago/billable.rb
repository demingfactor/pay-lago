module Pay
  module Lago
    class Billable
      require "uri"

      attr_reader :pay_customer

      delegate :processor_id,
        :processor_id?,
        :email,
        :customer_name,
        :card_token,
        to: :pay_customer

      def initialize(pay_customer)
        @pay_customer = pay_customer
      end

      def pay_external_id
        processor_id || pay_customer.to_gid.to_s
      end

      # Returns a hash of attributes for the Lago::Customer object
      def customer_attributes(external_id)
        owner = pay_customer.owner

        attributes = case owner.class.pay_lago_customer_attributes
        when Symbol
          owner.send(owner.class.pay_lago_customer_attributes, pay_customer)
        when Proc
          owner.class.pay_lago_customer_attributes.call(pay_customer)
        end

        # Guard against attributes being returned nil
        attributes ||= {}

        {external_id: external_id, email: email, name: customer_name}.merge(attributes)
      end

      def customer
        begin
          lago_customer = Lago.client.customers.get(pay_external_id)
        rescue ::Lago::Api::HttpError
          lago_customer = Lago.client.customers.create(customer_attributes(pay_external_id))
        end
        pull!(lago_customer)
        lago_customer
      rescue ::Lago::Api::HttpError => e
        raise Pay::Lago::Error, e
      end

      def update_customer!(attributes = {})
        attributes = symbolize_recursive(attributes)
        new_attributes = Lago.openstruct_to_h(customer).except(:lago_id)
        lago_customer = Lago.client.customers.create(
          new_attributes.merge(attributes.except(:external_id))
        )
        pull!(lago_customer)
        lago_customer
      end

      def pull!(lago_customer = customer, force: false)
        if pay_customer.processor_id.present? && pay_customer.processor_id != lago_customer.external_id && !force
          raise Pay::Lago::Error.new("Error syncing Lago Customer: IDs do not match!")
        end
        new_data = Pay::Lago.openstruct_to_h(lago_customer)
        pay_customer.update!(processor_id: lago_customer.external_id, data: new_data)
      end

      def push!
        update_customer!(pay_customer.data)
      end

      def charge(amount = nil, addon: nil, options: {})
        lago_customer = customer
        lago_addon = addon.is_a?(String) ? Lago.client.add_ons.get(addon) : pay_default_addon
        amount ||= lago_addon.amount_cents

        attributes = {
          external_customer_id: processor_id,
          currency: options[:currency] || lago_customer.currency,
          fees: [
            {
              add_on_code: lago_addon.code,
              unit_amount_cents: amount
            }.merge(options.except(:amount_cents, :add_on_code, :currency))
          ]
        }

        invoice = Lago.client.invoices.create(attributes)
        Pay::Lago::Charge.sync(invoice.lago_id, object: invoice)
      rescue ::Lago::Api::HttpError => e
        raise Pay::Lago::Error, e
      end

      def subscribe(name: Pay.default_product_name, plan: Pay.default_plan_name, **options)
        # Make to generate a processor_id
        lago_customer = customer
        pay_subscription = create_placeholder_subscription(name, plan)
        external_id = pay_subscription.to_gid.to_s

        attributes = options.merge(
          external_customer_id: lago_customer.external_id,
          name: name, external_id: external_id, plan_code: plan
        )

        begin
          subscription = Lago.client.subscriptions.create(attributes)
        rescue ::Lago::Api::HttpError => e
          pay_subscription.destroy!
          raise Pay::Lago::Error, e
        end

        pay_subscription.update!(processor_id: external_id)
        Pay::Lago::Subscription.sync(lago_customer.external_id, external_id, object: subscription)
      end

      def get_payment_method(provider, provider_id = nil)
        raise Pay::Lago::Error.new("Invalid provider!") unless Pay::Lago::PaymentMethod.valid_provider?(provider)
        if provider_id.present?
          Pay::PaymentMethod.find_by_lago_provider_and_id(provider, provider_id)
        else
          Pay::PaymentMethod.with_provider(provider).first
        end
      end

      def add_payment_method(provider, provider_id, default: true, sync: true, options: {})
        raise Pay::Lago::Error.new("Invalid provider!") unless Pay::Lago::PaymentMethod.valid_provider?(provider)

        payment_method = pay_customer.payment_methods.with_provider(provider).where(processor_id: provider_id).first
        payment_method ||= Pay::PaymentMethod.create(
          processor_id: provider_id,
          type: "card",
          customer: pay_customer, data: options.merge(payment_provider: provider, provider_customer_id: provider_id)
        )

        payment_method.make_default! if default || sync
        payment_method.payment_processor.push! if sync

        payment_method
      end

      def clear_payment_method!
        data = (pay_customer.data || {}).merge(
          "billing_configuration": {payment_provider: nil, payment_method_id: nil, provider_customer_id: nil, provider_payment_methods: nil}
        )
        update_customer!(data)
      end

      def processor_subscription(subscription_id, **_options)
        Pay::Lago.client.subscriptions.get(subscription_id)
      end

      def trial_end_date(subscription)
        raise Pay::Lago::Error.new("Lago subscriptions do not implement trials.")
      end

      private

      def create_placeholder_subscription(name, plan)
        pay_customer.subscriptions.create!(
          processor_id: NanoId.generate,
          name: name,
          processor_plan: plan,
          quantity: 0,
          status: "incomplete"
        )
      end

      def pay_default_addon
        begin
          Lago.client.add_ons.get("pay_default_addon")
        rescue ::Lago::Api::HttpError
          Lago.client.add_ons.create(
            name: "Default Charge",
            code: "pay_default_addon",
            amount_cents: 100,
            amount_currency: "USD"
          )
        end
      rescue ::Lago::Api::HttpError => e
        raise Pay::Lago::Error, e
      end

      def symbolize_recursive(hash)
        return hash unless hash.is_a? Hash
        hash.map { |key, value| [key.is_a?(String) ? key.to_sym : key, symbolize_recursive(value)] }.to_h
      end
    end
  end
end
