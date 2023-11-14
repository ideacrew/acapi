require 'bunny'

module Acapi
  class Requestor
    class DoNothingRequestor
      def request(*args)
        nil
      end

      def reconnect!
      end

      def disconnect!
      end

    end

    class AmqpRequestor
      def initialize(app_id, uri)
        @app_id = app_id
        @uri = uri
      end

      def request(req_name, payload,timeout=1)
        open_connection_for_request
        requestor = ::Acapi::Amqp::Requestor.new(@connection)
        req_time = Time.now
        msg = ::Acapi::Amqp::OutMessage.new(@app_id, req_name, req_time, req_time, nil, payload)
        response = requestor.request(*msg.to_request_properties(timeout))
        in_msg = ::Acapi::Amqp::InMessage.new(*response)
        in_msg.to_response
      end

      def open_connection_for_request
        return if @connection.present? && @connection.connected?
        @connection = Bunny.new(@uri, :heartbeat => 15)
        @connection.start
      end

      def reconnect!
        disconnect!
        @connection = Bunny.new(@uri, :heartbeat => 15)
        @connection.start
      end

      def disconnect!
        if @connection
          begin
            @connection.close
          rescue Timeout::Error
          end
        end
      end
    end

    # :nodoc:
    # @private
    def self.instance
      return nil if !defined?(@@instance)
      @@instance
    end

    # :nodoc:
    # @private
    def self.reconnect!
      instance.reconnect!
    end

    # :nodoc:
    # @private
    def self.disable!
      if instance
        instance.disconnect!
      end
      @@instance = DoNothingRequestor.new
    end

    # :nodoc:
    # @private
    def self.boot!(app_id, uri, ex_name)
      @@instance = ::Acapi::Requestor::AmqpRequestor.new(app_id, uri)
    end

    def self.request(req_name, payload, timeout=1)
      instance.request(req_name, payload,timeout)
    end
  end
end
