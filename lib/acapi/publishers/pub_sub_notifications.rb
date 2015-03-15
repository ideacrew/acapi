module Acapi
  module Publishers

    # handle different attachments of publishers to a model
    class PubSubNotifications
  
      attr_reader :publishers_info, :model
  
      def initialize(model)
        @model = model
        @publishers_info = {}
      end
  
      def attach_publisher(namespace, publisher_name)
        publishers_info[namespace] ||= Acapi::Publishers::NotificationsQueue.new(publisher_name)
        true
      end
  
      def reset_notifications(namespace)
        publishers_info[namespace].reset_notifications
      end
  
      def add_notification(namespace, event_name, payload={})
        publishers_info[namespace].add_notification(event_name, payload)
      end
  
      def prepare_created(namespace)
        add_notification(namespace, 'created') if model.new_record?
      end
  
      def prepare_destroyed(namespace)
        add_notification(namespace, 'destroyed') if model.destroyed?
      end
  
      def prepare_notifications(namespace)
        publishers_info[namespace].publisher.prepare_notifications(namespace, model)
  
        return true
      end
  
      def publish_notifications(namespace)
        publishers_info[namespace].notifications.each do |notification|
          broadcast_event(
              [namespace, notification[:event_name]].compact.join('.'),
              notification[:payload].merge(model: model)
          )
        end
  
        return true
      end
  
    end
  end
end