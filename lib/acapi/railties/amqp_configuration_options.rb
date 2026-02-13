require 'uri'

module Acapi
  class ClusterSettings
    attr_accessor :hosts
    attr_accessor :port
    attr_accessor :username
    attr_accessor :password

    def to_connection_settings
      {
        :hosts => @hosts,
        :port => @port || 5672,
        :username => @username || "guest",
        :password => @password || "guest",
        :heartbeat => 10
      }
    end
  end

  class ConfigurationSettings
    attr_accessor :remote_broker_uri
    attr_accessor :remote_event_queue
    attr_accessor :remote_request_exchange
    attr_accessor :hbx_id
    attr_accessor :environment_name

    def clear!
      @remote_broker_uri = nil
      @remote_event_queue = nil
      @remote_request_exchange = nil
      @hbx_id = nil
      @environment_name = nil
      @cluster = nil
    end

    def empty_connection_settings?
      remote_broker_uri.blank? && @cluster.blank?
    end

    def cluster
      @cluster ||= Acapi::ClusterSettings.new
      yield @cluster if block_given?
      @cluster
    end

    def to_connection_settings
      raise ::Acapi::Errors::RemoteConnectionUnspecifiedError.new("No remote broker connection specified") if empty_connection_settings?
      @connection_settings_hash ||= encode_connection_settings
    end

    def encode_connection_settings
      if @cluster.blank?
        uri = URI.parse(remote_broker_uri)
        port_value = uri.port.blank? ? 5672 : uri.port
        user_value = uri.user.blank? ? "guest" : uri.user
        password_value = uri.password.blank? ? "guest" : uri.password
        {
          :host => uri.host,
          :port => port_value,
          :username => user_value,
          :password => password_value,
          :heartbeat => 10
        }
      else
        cluster.to_connection_settings
      end
    end
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
        setting = Rails.application.config.acapi
        r_exchange = Rails.application.config.acapi.remote_request_exchange
        if Rails.application.config.acapi.empty_connection_settings?
          disable_requestor
        else
          boot_requestor(app_id, setting.to_connection_settings, r_exchange)
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
