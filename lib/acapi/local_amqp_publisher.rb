require 'bunny'

module Acapi
  class LocalAmqpPublisher
    QUEUE_NAME = "acapi.events.local"

    class DoNothingPublisher
      def log(*args)
      end

      def reconnect!
      end

      def disconnect!
      end
    end

    class LoggingPublisher 
      def log(*args)
        Rails.logger.info "Acapi::LocalAmqpPublisher - Logging subscribed event:\n#{args.inspect}"
      end

      def reconnect!
      end

      def disconnect!
      end
    end

    def self.instance
      @@instance
    end

    def self.logging!
      if defined?(@@instance) && !@instance.nil?
        @@instance.disconnect!
      end
      @@instance = LoggingPublisher.new
    end

    def self.disable!
      if defined?(@@instance) && !@instance.nil?
        @@instance.disconnect!
      end
      @@instance = DoNothingPublisher.new
    end

    def self.boot!(app_id)
      conn = Bunny.new
      conn.start
      ch = conn.create_channel
      queue = ch.queue(QUEUE_NAME, {:durable => true})
      @@instance = self.new(conn, ch, queue, app_id)
    end

    def initialize(conn, ch, queue, app_id)
      @app_id = app_id
      @connection = conn
      @channel = ch
      @queue = queue
    end

    def log(name, started, finished, unique_id, data = {})
      if data.has_key?(:app_id) || data.has_key?("app_id")
        return
      end
      msg = Acapi::Amqp::OutMessage.new(@app_id, name, finished, finished, unique_id, data)
      @queue.publish(*msg.to_message_properties)
    end

    def reconnect!
      disconnect!
      @connection = Bunny.new
      @connection.start
      @channel = @connection.create_channel
      @queue = @channel.queue(QUEUE_NAME, {:durable => true})
    end

    def disconnect!
      @connection.close
    end

    def self.reconnect!
      instance.reconnect!
    end

    def self.log(name, started, finished, unique_id, data)
      instance.log(name, started, finished, unique_id, data)     
    end
  end
end
