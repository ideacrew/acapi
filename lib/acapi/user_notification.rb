module Acapi
  class UserNotification
    def initialize(kind, recipient, subject, body)
      @kind = kind
      @recipient = recipient
      @subject = subject
      @body = body
    end

    def publish!
      ActiveSupport::Notifications.instrument(
        "acapi.info.user_notification.#{@kind.downcase}.published",
        { :subject => @subject, :body => @body, :recipient => @recipient }
      )
    end
  end
end
