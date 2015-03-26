module Acapi
  module Publishers

    # capture attachment of a publisher to a model in a namespace
    class NotificationsQueue
      attr_reader :publisher, :notifications
  
      def initialize(publisher_name)
        # this is a problem Family.new
        @publisher = publisher_name.to_s.constantize.new
        @notifications = []
      end
  
      def add_notification(event_name, payload={})
        @notifications << {event_name: event_name, payload: payload}
      end
  
      def reset_notifications
        @notifications = []
      end
    end
  end

end
