require "securerandom"

module Acapi
  module Amqp
    class InMessage
      def initialize(di, props, msg)
        @delivery_info = di
        @props = props
        @body = msg
      end

      def to_instrumented_event
        properties = @props.to_hash.dup
        rk_name = extract_event_name(@delivery_info)
        msg_id = @props.message_id # Generate guid if not provided
        msg_id ||= SecureRandom.uuid.gsub("-", "")
        stime = extract_start_time(properties)
        payload = extract_payload(properties, @body)
        [rk_name, stime, stime, msg_id, payload]
      end

      def extract_start_time(props)
        headers = props[:headers] || {}
        ts_val = Time.now
        if headers.has_key?("submitted_timestamp")
          ts_val = headers["submitted_timestamp"]
        elsif headers.has_key?(:submitted_timestamp)
          ts_val = headers[:submitted_timestamp]
        end
        ts_val
      end

      def extract_event_name(di)
        "acapi." + di.routing_key
      end

      def extract_payload(props, payload)
        properties = props.dup
        headers = properties.delete(:headers) || {}
        properties.merge(headers).merge({:body => payload})
      end

      def to_response
        to_instrumented_event.last
      end
    end
  end
end
