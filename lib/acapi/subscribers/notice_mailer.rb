module Acapi
  module Subscribers

    class NoticeMailer < ::Subscribers::Base
      def user_signed_up(event)
        # lets delay the delivery using delayed_job
        NoticeMailer.delay(priority: 1).welcome_email(event.payload[:person])
      end
    end
    
  end
end