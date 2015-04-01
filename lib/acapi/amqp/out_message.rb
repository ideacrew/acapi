require 'securerandom'

module Acapi
  module Amqp
    class OutMessage 
      def initialize(a_id, e_name, s_time, e_time, m_id, p = {})
        @app_id = a_id
        @event_name = e_name
        @start_time = s_time
        @end_time = e_time
        @message_id = m_id
        @message_id ||= SecureRandom.uuid.gsub("-","")
        @payload = p
      end

      def to_message_properties
        message_data = @payload.dup
        body_data = message_data.delete(:body)
        body_data = body_data.nil? ? "" : body_data.to_s
        message_props = {
          :routing_key => @event_name.sub(/\Aacapi\./, ""),
          :app_id => @app_id,
          :headers => ({
            :submitted_timestamp => @end_time
          }).merge(message_data)
        }
        [body_data, message_props]
      end

      def to_request_properties(timeout = 1)
        message_data = @payload.dup
        body_data = message_data.delete(:body)
        body_data = body_data.nil? ? "" : body_data.to_s
        message_props = {
          :routing_key => @event_name,
          :app_id => @app_id,
          :headers => ({
            :submitted_timestamp => @end_time
          }).merge(message_data)
        }
        [body_data, message_props, timeout]
      end
    end
  end
end
