require "acapi/publishers/notifications_queue"
require "acapi/publishers/pub_sub_notifications"

module Acapi
  module Publishers
    extend ::ActiveSupport::Concern
    extend self

    included do
      # add support for namespace, one class - one namespace
      class_attribute :pub_sub_namespace
   
      self.pub_sub_namespace = nil
    end

    # Publish passed event using ActiveSupport::Notifications (ASN)
    def broadcast_event(event_name, payload={})
      if block_given?
         ActiveSupport::Notifications.instrument(event_name, payload) do
           yield
         end
      else
        ActiveSupport::Notifications.instrument(event_name, payload)
      end
    end

    module ClassMethods
      # delegate to ASN
      def broadcast_event(event_name, payload={})
        event_name = [pub_sub_namespace, event_name].compact.join('.')
        if block_given?
          ActiveSupport::Notifications.instrument(event_name, payload) do
            yield
          end
        else
          ActiveSupport::Notifications.instrument(event_name, payload)
        end
      end
    end
  end
end
