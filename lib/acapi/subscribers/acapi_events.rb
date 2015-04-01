module Acapi
  module Subscribers
    class AcapiEvents
      def self.register
        ActiveSupport::Notifications.subscribe(/\Aacapi\./) do |e_name, e_start, e_end, msg_id, payload|
          Acapi::LocalAmqpPublisher.log(e_name, e_start, e_end,msg_id, payload)
        end
      end
    end
  end
end
