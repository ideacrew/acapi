module Acapi
  class ConfigurationSettings
    attr_accessor :remote_broker_uri
    attr_accessor :remote_event_queue
    attr_accessor :remote_request_exchange
    attr_accessor :hbx_id
    attr_accessor :environment_name
  end
end

module Rails
  class Application
    class Configuration < Rails::Engine::Configuration
      # @return [Acapi::ConfigurationSettings]
      def acapi
        @acapi ||= ::Acapi::ConfigurationSettings.new
      end
    end
  end
end

module Acapi
  # :nodoc:
  # @private
  module Railties
    # :nodoc:
    # @private
    class AmqpConfigurationSettings < Rails::Railtie
      config.after_initialize do |app|
        app_id = Rails.application.config.acapi.app_id
        setting = Rails.application.config.acapi.remote_broker_uri
        r_exchange = Rails.application.config.acapi.remote_request_exchange
        if !setting
          disable_requestor
        else
          boot_requestor(app_id, setting, r_exchange)
        end
      end

      def disable_requestor
        Rails.logger.info "Setting 'acapi.remote_broker_uri' not provided - disabling requestor."
        ::Acapi::Requestor.disable!
      end

      def boot_requestor(app_id, uri, r_exchange)
        ::Acapi::Requestor.boot!(app_id, uri, r_exchange)
      end
    end
  end
end
