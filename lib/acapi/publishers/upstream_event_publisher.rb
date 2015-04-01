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

      def extract_start_time(props)
        headers = props[:headers] || {}
        ts_val = headers["submitted_timestamp"]
        ts_val.blank? ? Time.now : ts_val
      end

      def extract_event_name(di)
        "acapi." + di.routing_key
      end

      def extract_payload(props, body)
        properties = props.dup
        headers = properties.delete(:headers) || {}
        properties.merge(headers).merge({:body => body})
      end

      def handle_message(app_id, di, props, body)
        if app_id == props.app_id
          return
        end
        properties = props.to_hash.dup
        rk_name = extract_event_name(di)
        msg_id = properties[:message_id] # Also provide GUID if not provided
        stime = extract_start_time(properties)
        payload = extract_payload(properties, body)
        byebug
        ::ActiveSupport::Notifications.publish(rk_name, stime, stime, msg_id, payload)
      end
    end
  end
end
