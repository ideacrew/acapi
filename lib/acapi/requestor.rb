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
      def initialize(app_id, uri, conn, chan)
        @app_id = app_id
        @uri = uri
        @connection = conn
        @channel = chan
      end

      def request(req_name, payload,timeout=1)
        requestor = ::Acapi::Amqp::Requestor.new(@channel.connection)
        req_time = Time.now
        msg = ::Acapi::Amqp::OutMessage.new(@app_id, req_name, req_time, req_time, nil, payload)
        response = requestor.request(*msg.to_request_properties(timeout))
        in_msg = ::Acapi::Amqp::InMessage.new(*response)
        in_msg.to_response
      end

      def reconnect!
        disconnect!
        @connection = Bunny.new(@uri)
        @connection.start
        @channel = @connection.create_channel
      end

      def disconnect!
        @connection.close
      end
    end

    def self.reconnect!
      @@instance.reconnect!
    end

    def self.disable!
      if defined?(@@instance) && !@@instance.nil?
        @@instance.disconnect!
      end
      @@instance = DoNothingRequestor.new
    end

    def self.boot!(app_id, uri)
      if defined?(@@instance) && !@@instance.nil?
        @@instance.disconnect!
      end
      conn = Bunny.new(uri, :heartbeat => 1)
      conn.start
      slug_channel = conn.create_channel # We need a slug default channel
      @@instance = ::Acapi::Requestor::AmqpRequestor.new(app_id, uri, conn, slug_channel)
    end

    def self.request(req_name, payload, timeout=1)
      @@instance.request(req_name, payload,timeout)
    end
  end
end
