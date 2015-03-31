module Acapi
  module Publishers
    # In this class, we load the needed amqp connections and information to
    # listen for AMQP events, and then propagate them to the instrumentation.
    # The implementation is Forkr compatible.
    class UpstreamEventPublisher
      def initialize(&after_fork)
        @after_fork = after_fork
      end

      def run
        if @after_fork
          @after_fork.call
        end
      end

      def republish_message(di, props, body)
        rk_name = extract_event_name(di)
        msg_id = extract_message_id(props)
        stime = extract_start_time(props)
        payload = extract_payload(di, props, body)
        ActiveSuppport::Notifications.publish(rk_name, stime, stime, msg_id, payload)
      end
    end
  end
end
