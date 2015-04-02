module Acapi
  class UserNotification
    def initialize(kind, recipient, subject, body)
      @kind = kind
      @recipient = recipient
      @subject = subject
      @body = body
    end

    def publish!
      message_kind, payload = construct_arguments
      ActiveSupport::Notifications.instrument(
        "acapi.info.user_notifications.#{message_kind.downcase}.published",
        payload
      )
    end

    def construct_arguments
      args = { 
        :subject => @subject,
        :body => @body,
        :recipient => @recipient
      }
      case @kind
      when :email_html
        [:email, args.merge({:format => "html"})]
      else
        [:email, args]
      end
    end
  end
end
