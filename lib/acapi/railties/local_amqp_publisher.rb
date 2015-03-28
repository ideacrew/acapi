module Acapi
  module Railties
    class LocalAmqpPublisher < Rails::Railtie

      initializer "local_amqp_publisher_railtie.configure_rails_initialization" do |app|
        # TODO: Configure local event publishing client
        publish_enabled = app.config.acapi.publish_amqp_events
        if publish_enabled
        else
        end
      end

    end
  end
end
