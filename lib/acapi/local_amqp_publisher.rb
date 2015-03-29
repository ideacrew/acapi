require 'bunny'

module Acapi
  class LocalAmqpPublisher
    QUEUE_NAME = "acapi.events.local"

    class DoNothingPublisher
      def log(*args)
      end

      def format_log_message

      end

      def reconnect!
      end
    end

    def self.instance
      @@instance
    end

    def self.disable!
      @@instance = DoNothingPublisher.new
    end

    def self.boot!
      conn = Bunny.new
      conn.start
      ch = conn.create_channel
      queue = ch.queue(QUEUE_NAME, {:persistent => true})
      @@instance = self.new(conn, ch, queue)
    end

    def initialize(conn, ch, queue)
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
        :headers => {
          :submitted_timestamp => finished
        }.merge(data)
      }
      @queue.publish(body_data, message_props)
    end

    def reconnect!
      @connection.close
      @connection = Bunny.new
      @connection.start
      @channel = @connection.create_channel
      @queue = @channel.queue(QUEUE_NAME, {:persistent => true})
    end

    def self.reconnect!
      instance.reconnect!
    end

    def self.log(name, started, finished, unique_id, data)
      instance.log(name, started, finished, unique_id, data)     
    end
  end
end
