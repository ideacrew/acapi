module Acapi
  module Subscribers 
    module CorpLogger
      def self.register(event_name)
        ActiveSupport::Notifications.subscribe event_name do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          puts event.name
          puts event.time
          puts event.end
          puts event.duration
          puts event.transaction_id
          puts event.payload
          event.payload[:blk].call
        end
      end 
    end 
  end
end
