module Acapi
  module Railties
    class LocalAmqpSubscriber < Rails::Railtie

      initializer "local_amqp_subscriber_railtie.configure_rails_initialization" do |app|
        subscribe_enabled = true
        if subscribe_enabled.blank?
          warn_settings_not_specified
        end

        if subscribe_enabled
          boot_local_subscriber
        end
      end

      def warn_settings_not_specified
        Rails.logger.info "No setting specified for 'acapi.subscribe_amqp_events' - disabling subscriber of events to local AMQP instance'"
      end

      def boot_local_subscriber
        ::Acapi::LocalAmqpSubscriber.boot!
      end 
    end
  end
end
