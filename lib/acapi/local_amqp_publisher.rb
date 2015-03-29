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

    def log(name, started, finished, unique_id, data)
    end

    def reconnect!
    end

    def self.reconnect!
      instance.reconnect!
    end

    def self.log(name, started, finished, unique_id, data)
      instance.log(name, started, finished, unique_id, data)     
    end
  end
end
