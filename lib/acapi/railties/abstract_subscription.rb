module Acapi
    class ConfigurationSettings
      def add_subscription(subscription)
        @additional_event_subscriptions ||= []
        @additional_event_subscriptions << subscription
        @additional_event_subscriptions.uniq!
      end

      def register_all_additional_subscriptions
        @additional_event_subscriptions ||= []
        @additional_event_subscriptions.each(&:subscribe)
      end
    end
end

module Acapi
    module Railties
          class AbstractSubscription < Rails::Railtie
            config.after_initialize do |app|
              app.config.acapi.register_all_additional_subscriptions
            end
          end
    end
end
