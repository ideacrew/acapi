module Acapi
  class Subscription
    def self.subscription_details
      raise NotImplementedError, "define in subclass"
    end

    def call(event_name, e_start, e_end, msg_id, payload)
      raise NotImplementedError, "define in subclass"
    end

    def self.subscribe
      ActiveSupport::Notifications.subscribe(*self.subscription_details) do |e_name, e_start, e_end, msg_id, payload|
        self.new.call(e_name, e_start,e_end,msg_id,payload)
      end
    end
  end
end
