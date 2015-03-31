module Acapi
  module Subscribers 
    module Logger
      def self.register(event_name)
        ActiveSupport::Notifications.subscribe event_name do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          #event.payload[:blk].call if event.payload[:blk]
          puts event.name
          Acapi::LocalAmqpPublisher.log(event.name, event.time, event.end, event.transaction_id, event.payload)
        end
      end
    end 
  end
end
