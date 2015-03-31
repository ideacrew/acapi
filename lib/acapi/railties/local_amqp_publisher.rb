module Acapi
  class ConfigurationSettings
    attr_accessor :publish_amqp_events, :app_id, :subscribe_amqp_events
  end
  
end

module Acapi
  module Railties
    class LocalAmqpPublisher < Rails::Railtie

      initializer "local_amqp_publisher_railtie.configure_rails_initialization" do |app|
        publish_enabled = true
        if publish_enabled.blank?
          warn_settings_not_specified
        end
        if publish_enabled
          boot_local_publisher
        else
          disable_local_publisher
        end
      end

      def warn_settings_not_specified
        Rails.logger.info "No setting specified for 'acapi.publish_amqp_events' - disabling publishing of events to local AMQP instance'"
      end

      def boot_local_publisher
        ::Acapi::LocalAmqpPublisher.boot!
      end

      def disable_local_publisher
        ::Acapi::LocalAmqpPublisher.disable!
      end
    end
  end
end
