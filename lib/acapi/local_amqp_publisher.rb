require 'bunny'

module Acapi
  class LocalAmqpPublisher
    QUEUE_NAME = "acapi.events.local"

    class DoNothingPublisher
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

    def self.disable!
      if @@instance
        @@instance.disconnect!
      end
      @@instance = DoNothingPublisher.new
    end

    def self.boot!(app_id)
      conn = Bunny.new
      conn.start
      ch = conn.create_channel
      queue = ch.queue(QUEUE_NAME, {:persistent => true})
      @@instance = self.new(conn, ch, queue, app_id)
    end

    def initialize(conn, ch, queue, app_id)
      @app_id = app_id
      @connection = conn
      @channel = ch
      @queue = queue
    end

    def log(name, started, finished, unique_id, data = {})
      message_data = data.dup
      body_data = message_data.delete(:body)
      body_data = body_data.nil? ? "" : body_data.to_s
      message_props = {
        :routing_key => name.sub(/\Aacapi\./, ""),
        :app_id => @app_id,
        :headers => {
          :submitted_timestamp => finished
        }.merge(data)
      }
      @queue.publish(body_data, message_props)
    end

    def reconnect!
      disconnect!
      @connection = Bunny.new
      @connection.start
      @channel = @connection.create_channel
      @queue = @channel.queue(QUEUE_NAME, {:persistent => true})
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
