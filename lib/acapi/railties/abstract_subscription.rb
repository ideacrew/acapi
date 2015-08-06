module Acapi
    class ConfigurationSettings
      def constantize_subscriber(sub_name)
        return(sub_name) unless sub_name.kind_of?(String)
        sub_name.constantize
      end

      def add_async_subscription(subscription)
        @additional_async_event_subscriptions ||= []
        @additional_async_event_subscriptions << subscription
        @additional_async_event_subscriptions.uniq!
      end

      def add_subscription(subscription)
        @additional_event_subscriptions ||= []
        @additional_event_subscriptions << subscription
        @additional_event_subscriptions.uniq!
      end

      def register_all_additional_subscriptions
        @additional_event_subscriptions ||= []
        @additional_event_subscriptions.each do |sub|
          constantize_subscriber(sub).subscribe
        end
      end

      def register_async_subscribers!
        @additional_async_event_subscriptions ||= []
        @additional_async_event_subscriptions.each do |sub|
          constantize_subscriber(sub).subscribe
        end
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
