require 'acapi/local_amqp_publisher'

module Acapi
  module Subscribers 
    class Edi < Acapi::Subscription
      def self.subscription_details
        ["acapi.info.events.enrollment.submitted"]
      end

      def call(event_name, e_start, e_end, msg_id, payload) 
        Acapi::LocalAmqpPublisher.log(event_name, (e_end - e_start), e_end, msg_id, payload)
      end
    end 
  end
end
