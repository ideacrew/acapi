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
        bunny_url = Rails.application.config.acapi.remote_broker_uri
        event_q_name = Rails.application.config.acapi.remote_event_queue
        app_id = Rails.application.config.acapi.app_id
        conn = Bunny.new(bunny_url)
        conn.start
        chan = conn.create_channel
        chan.prefetch(1)
        begin
          event_q = chan.queue(event_q_name, {:persistent => true})
          event_q.subscribe(:block => true, :manual_ack => true) do |delivery_info, properties, payload|
            handle_message(app_id, delivery_info, properties, payload)
            chan.acknowledge(delivery_info.delivery_tag, false)
          end
        ensure
          conn.close
        end
      end

      def handle_message(app_id, di, props, body)
        if app_id == props.app_id
          return
        end
        msg = ::Acapi::Amqp::InMessage.new(di, props, body)
        Rails.log.info msg.to_instrumented_event.inspect
        ActiveSupport::Notifications.publish(*msg.to_instrumented_event)
      end
    end
  end
end
