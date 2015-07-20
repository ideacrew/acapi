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
        stime = extract_time_value(properties)
        payload = extract_payload(properties, @body)
        [rk_name, stime, stime, msg_id, payload]
      end


      def extract_time_value(props)
        time_from_submitted = extract_start_time(props)
        time_from_timestamp = extract_timestamp_prop(props)
        if !time_from_submitted.nil?
          return time_from_submitted
        elsif !time_from_timestamp.nil?
          return time_from_timestamp
        end
        Time.now
      end

      def extract_timestamp_prop(props)
        if props.has_key?(:timestamp)
          return(Time.at(props[:timestamp].to_i) rescue nil)
        elsif props.has_key?("timestamp")
          return(Time.at(props["timestamp"].to_i) rescue nil)
        end
      end

      def extract_start_time(props)
        headers = props[:headers] || {}
        if headers.has_key?("submitted_timestamp")
          return(parse_submitted_at(headers["submitted_timestamp"]))
        elsif headers.has_key?(:submitted_timestamp)
          return(parse_submitted_at(headers[:submitted_timestamp]))
        end
        nil
      end

      def parse_submitted_at(val)
        if val.kind_of?(Time)
          return val
        end
        ActiveSupport::TimeZone.new("UTC").parse(val) rescue nil
      end

      def extract_event_name(di)
        "acapi." + di.routing_key
      end

      def extract_payload(props, payload)
        properties = props.dup
        headers = properties.delete(:headers) || {}
        properties.merge(headers).merge({:body => payload, "x_no_rebroadcast" => true})
      end

      def to_response
        to_instrumented_event.last
      end
    end
  end
end
