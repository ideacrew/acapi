module Acapi
  module Railties
    class LocalAmqpPublisher < Rails::Railtie

      initializer "local_amqp_publisher_railtie.configure_rails_initialization" do |app|
        # TODO: Configure local event publishing client
        publish_enabled = app.config.acapi.publish_amqp_events
        if publish_enabled
          boot_local_publisher
        else
          disable_local_publisher
        end
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
