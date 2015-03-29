module Acapi
  module Railties
    class LocalAmqpPublisher < Rails::Railtie

      initializer "local_amqp_publisher_railtie.configure_rails_initialization" do |app|
        # TODO: Configure local event publishing client
        publish_enabled = lookup_publisher_configuration(app)
        if publish_enabled.blank?
          warn_settings_not_specified
        end
        if publish_enabled
          boot_local_publisher
        else
          disable_local_publisher
        end
      end

      def self.lookup_publisher_configuration(app)
        r_config = app.config
        return nil unless r_config.respond_to?(:acapi)
        acapi_config = r_config.acapi
        return nil unless acapi_config.respond_to?(:publish_amqp_events)
        acapi_config.publish_amqp_events
      end

      def self.warn_settings_not_specified
        Rails.logger.info "No setting specified for 'acapi.publish_amqp_events' - disabling publishing of events to local AMQP instance'"
      end

      def self.boot_local_publisher
        ::Acapi::LocalAmqpPublisher.boot!
      end

      def self.disable_local_publisher
        ::Acapi::LocalAmqpPublisher.disable!
      end
    end
  end
end
