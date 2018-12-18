module Acapi
  module Publishers
    # In this class, we load the needed amqp connections and information to
    # listen for AMQP events, and then propagate them to the instrumentation.
    # The implementation is Forkr compatible.
    class UpstreamEventPublisher
      include ::Acapi::Notifiers

      def initialize(&after_fork)
        @after_fork = after_fork
      end

      def register_subscribers!
        Rails.application.config.acapi.register_async_subscribers!
      end

      def run
        if @after_fork
          @after_fork.call
        end
        bunny_url = Rails.application.config.acapi.remote_broker_uri
        event_q_name = Rails.application.config.acapi.remote_event_queue
        app_id = Rails.application.config.acapi.app_id
        conn = Bunny.new(bunny_url, :heartbeat => 15)
        conn.start
        chan = conn.create_channel
        chan.prefetch(1)
        begin
          event_q = chan.queue(event_q_name, {:durable => true})
          event_q.subscribe(:block => true, :manual_ack => true) do |delivery_info, properties, payload|
            begin
              payload.force_encoding('UTF-8')
              handle_message(app_id, delivery_info, properties, payload)
              chan.acknowledge(delivery_info.delivery_tag, false)
            rescue Exception => e
              begin
                error_message = {
                  :error => {
                    :message => e.message,
                    :inspected => e.inspect,
                    :backtrace => e.backtrace.join("\n")
                  },
                  :original_payload => payload,
                  :original_properties => properties.to_hash
                }
                log(
                  JSON.dump(error_message),
                  {:level => "critical"}
                )
                chan.nack(delivery_info.delivery_tag, false, false)
              rescue Exception => x
                error_message = {
                  :message => x.message,
                  :inspected => x.inspect,
                  :backtrace => x.backtrace.join("\n")
                }
                STDERR.puts("=======CRASH!=======")
                STDERR.puts("Process Crashed: " + JSON.dump(error_message))
                throw :terminate, x
              end
            end
          end
        ensure
          conn.close
        end
      end

      def handle_message(app_id, di, props, body)
        msg = ::Acapi::Amqp::InMessage.new(di, props, body)
        ActiveSupport::Notifications.publish(*msg.to_instrumented_event)
      end
    end
  end
end
