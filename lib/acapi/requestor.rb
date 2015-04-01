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
      def initialize(app_id, uri, conn, chan, exchange_name)
        @app_id = app_id
        @uri = uri
        @connection = conn
        @channel = chan
        @exchange_name = exchange_name
        @exchange = @channel.direct(@exchange_name, :durable => true)
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
        begin
          disconnect!
        rescue Timeout::Error
        end
        @connection = Bunny.new(@uri)
        @connection.start
        @channel = @connection.create_channel
        @exchange = @channel.direct(@exchange_name, :durable => true)
      end

      def disconnect!
        @connection.close
      end
    end

    def self.instance
      return nil if !defined?(@@instance)
      @@instance
    end

    def self.reconnect!
      instance.reconnect!
    end

    def self.disable!
      if instance
        instance.disconnect!
      end
      @@instance = DoNothingRequestor.new
    end

    def self.boot!(app_id, uri, ex_name)
      conn = Bunny.new(uri)
      conn.start
      channel = conn.create_channel(77) # We need a slug default channel
      @@instance = ::Acapi::Requestor::AmqpRequestor.new(app_id, uri, conn, channel, ex_name)
    end

    def self.request(req_name, payload, timeout=1)
      @@instance.request(req_name, payload,timeout)
    end
  end
end
