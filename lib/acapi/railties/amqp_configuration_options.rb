module Acapi
    class ConfigurationSettings
      attr_accessor :remote_broker_uri
      attr_accessor :remote_event_queue
      attr_accessor :remote_request_exchange
    end
end

class Rails::Application::Configuration < Rails::Engine::Configuration
    def acapi
      @acapi ||= ::Acapi::ConfigurationSettings.new
    end
end
