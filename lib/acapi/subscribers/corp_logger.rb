module Acapi
  module Subscribers 
    module CorpLogger
      def self.register
        ActiveSupport::Notifications.subscribe 'logger' do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)
          puts event.name
          puts event.time
          puts event.end
          puts event.duration
          puts event.transaction_id
          puts event.payload
        end
      end

      def forward_event(event) 
        Acapi::Subscribers::EnterpriseLogger.log(event.payload[:log])
      end

      def self.log(data)
        puts data
      end
    end

  end
end
