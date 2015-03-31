module Acapi
  module Publishers
    module Logger
      extend ActiveSupport::Concern

      def logger(msg="", &blk)
        payload = {body: msg}
        payload.merge!(blk: blk) if block_given?
        Acapi::Publishers.broadcast_event("acapi.logger", payload)
      end

      def self.listen_queue(queue, routing_key)
        Acapi::LocalAmqpSubscriber.subscribe(queue, routing_key) do |delivery_info, metadata, payload|
          Acapi::Publishers.broadcast_event("acapi.re." << routing_key, payload)
        end
      end
    end
  end
end
