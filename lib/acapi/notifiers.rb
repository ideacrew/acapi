module Acapi
  module Notifiers
    def log(message, opts = {})
      options = opts.dup
      severity = options.delete(:severity)
      severity ||= "info"
      app_id = Rails.application.config.acapi.app_id
      event_key = "acapi.#{severity}.application.#{app_id}.logging"
      ActiveSupport::Notifications.instrument(event_key, options.merge(:body => message))
    end

    def notify(event_name, payload = {})
      ActiveSupport::Notifications.instrument(event_name, payload)
    end

    def send_email(recipient, subject, body)
      ::Acapi::UserNotification.new(:email, recipient, subject, body).publish!
    end

    def send_email_html(recipient, subject, body)
      ::Acapi::UserNotification.new(:email_html, recipient, subject, body).publish!
    end
  end
end
