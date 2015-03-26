module Acapi
  module Subscribers 
    class EnterpriseLogger < ::Acapi::Subscribers::Base 
      def forward_event(event) 
        Acapi::Subscribers::EnterpriseLogger.log(event.payload[:log])
      end

      def self.log(data)
        puts data
      end
    end

  end
end
