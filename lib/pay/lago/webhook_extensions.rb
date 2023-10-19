module Pay
  module Lago
    module WebhookExtensions
      def rehydrated_event
        return to_recursive_ostruct(event) if processor == "lago"
        super
      end
    end
  end
end