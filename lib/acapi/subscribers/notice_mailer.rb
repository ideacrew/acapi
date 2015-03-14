module Acapi
  module Subscribers

    class NoticeMailer < ::Acapi::Subscribers::Base

      def send_message(event)

        Acapi::NoticeMailer.welcome_email(event.payload[:person])
      end
    end
    
  end
end