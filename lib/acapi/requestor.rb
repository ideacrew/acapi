require 'bunny'

module Acapi
  class Requestor
    class DoNothingRequestor
      def request(*args)
        ["", "", {}] 
      end

      def reconnect!
      end

      def disconnect!
      end

    end

    class AmqpRequestor
      def initialize(uri, conn)
        @uri = uri
        @connection = conn
      end

      def request(req_name, payload)
        requestor = ::Acapi::Amqp::Requestor.new(@connection)
        req_time = Time.now
        msg = ::Acapi::Amqp::OutMessage.new(req_name, req_time, req_time, nil, payload)
        in_msg = ::Acapi::Amqp::InMessage.new(*requestor.request(*msg.to_request_properties))
        in_msg.to_response
      end

      def reconnect!
        disconnect!
        @connection = Bunny.new(@uri)
        @connection.start
      end

      def disconnect!
        @connection.close
      end
    end

    def self.disable!
      if defined?(@@instance) && !@instance.nil?
        @@instance.disconnect!
      end
      @@instance = DoNothingRequestor.new
    end

    def self.boot!(uri)
      if defined?(@@instance) && !@instance.nil?
        @@instance.disconnect!
      end
      conn = Bunny.new(uri)
      conn.start
      @@instance = AmqpRequestor.new(uri, conn)
    end

    def self.request(req_name, payload)
      @@instance.request(req_name, payload)
    end
  end
end
