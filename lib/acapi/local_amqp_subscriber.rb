require 'bunny'

module Acapi
  class LocalAmqpSubscriber
    TOPIC_NAME = "acapi.topic.local"

    def self.instance
      @@instance
    end

    def self.boot!
      conn = Bunny.new
      conn.start
      ch = conn.create_channel
      exchange = ch.topic(TOPIC_NAME, :persistent => true)
      @@instance = self.new(conn, ch, exchange)
    end

    def initialize(conn, ch, exchange)
      @connection = conn
      @channel = ch
      @exchange = exchange
    end

    def subscribe(queue, routing_key, &block)
      @channel.queue(queue).bind(@exchange, :routing_key => routing_key).subscribe do |delivery_info, metadata, payload|
        block.call(delivery_info, metadata, payload) if block
        byebug
        puts "payload: #{payload}; routing_key: #{delivery_info.routing_key}"
      end
    end 

    def reconnect!
      @connection.close
      @connection = Bunny.new
      @connection.start
      @channel = @connection.create_channel
      @exchange = @channel.topic(TOPIC_NAME, :persistent => true)
    end

    def self.reconnect!
      instance.reconnect!
    end

    def self.subscribe(queue = "", routing_key, &block)
      instance.subscribe(queue, routing_key, &block)
    end
  end
end
