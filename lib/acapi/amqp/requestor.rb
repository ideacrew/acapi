require 'timeout'
require 'thread'

module Acapi
  module Amqp
    class Requestor
      def initialize(conn)
        @connection = conn
      end

      def request(properties, payload, timeout = 15)
        delivery_info, r_props, r_payload = [nil, nil, nil]
        channel = @connection.create_channel
        temp_queue = channel.queue("", :exclusive => true)
        channel.prefetch(1)
        request_exchange = channel.direct(Rails.application.config.acapi.remote_request_exchange, :durable => true)
        request_exchange.publish(payload, properties.dup.merge({ :reply_to => temp_queue.name, :persistent => true }))
        delivery_info, r_props, r_payload = [nil, nil, nil]
        begin
          Timeout::timeout(timeout) do
            temp_queue.subscribe({:manual_ack => true, :block => true}) do |di, prop, pay|
              delivery_info, r_props, r_payload = [di, prop, pay]
              channel.acknowledge(di.delivery_tag, false)
              throw :terminate, "success"
            end
          end
        ensure
          temp_queue.delete
        end
        [delivery_info, r_props, r_payload]
      end

    end
  end
end
