require 'bunny'

module Acapi
  class LocalAmqpPublisher
    QUEUE_NAME = "acapi.events.local"

    class DoNothingPublisher
      def log(*args)
      end
    end

    def self.instance
      @@instance
    end

    def self.disable!
      @@instance = DoNothingPublisher.new
    end

    def self.boot!
      @@instance = self.new
    end

    def initialize
      @connection = Bunny.new
      @connection.start
      @channel = @connection.create_channel
      @queue = @channel.queue(QUEUE_NAME, {:persistent => true})
    end

    def log(*args)
    end
  end
end
