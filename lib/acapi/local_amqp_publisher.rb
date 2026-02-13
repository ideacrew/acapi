require 'bunny'

module Acapi
  class LocalAmqpPublisher
    EXCHANGE_NAME = "acapi.exchange.events.local"
    QUEUE_NAME = "acapi.queue.events.local"

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
      @@instance = self.new(app_id)
    end

    def initialize(app_id)
      @app_id = app_id
    end

    def log(name, started, finished, unique_id, data = {})
      open_connection_if_needed
      if data.has_key?(:x_no_rebroadcast) || data.has_key?("x_no_rebroadcast")
        return
      end
      msg = Acapi::Amqp::OutMessage.new(@app_id, name, finished, finished, unique_id, data)
      @exchange.publish(*msg.to_message_properties)
      @p_channel.wait_for_confirms || raise(Acapi::Errors::PublishConfirmationFailedError, "message publication could not be confirmed")
    end

    def open_connection_if_needed
      return if @connection.present? && @connection.connected?
      @connection = Bunny.new(connection_url)
      @connection.start
      @channel = @connection.create_channel
      @queue = @channel.queue(QUEUE_NAME, {:durable => true})
      @p_channel = @connection.create_channel
      @p_channel.confirm_select
      @exchange = @p_channel.fanout(EXCHANGE_NAME, {:durable => true})
      @queue.bind(@exchange, {})
    end

    def connection_url
      Rails.application.config.acapi.to_connection_settings
    end

    def reconnect!
      disconnect!
    end

    def disconnect!
      if @connection
        begin
          @connection.close
        rescue Timeout::Error
        end
        @queue = nil
        @channel = nil
        @p_channel = nil
        @exchange = nil
        @connection = nil
      end
    end

    def self.reconnect!
      instance.reconnect!
    end

    def self.log(name, started, finished, unique_id, data)
      instance.log(name, started, finished, unique_id, data)     
    end
  end
end
