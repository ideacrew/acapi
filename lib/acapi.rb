require "acapi/version"
require "active_support"

require "acapi/config"
require "acapi/publisher"
require "acapi/subscriber"
require "acapi/notifiers"

require "acapi/subscribers/acapi_events"

require "acapi/amqp/in_message"
require "acapi/amqp/out_message"
require "acapi/amqp/requestor"
require "acapi/requestor"
require "acapi/local_amqp_publisher"

require "acapi/user_notification"
require "acapi/subscription"

module Acapi

  def configure
    block_given? ? yield(Config) : Config
  end

end

require "acapi/railties/amqp_configuration_options" if defined?(Rails)
require "acapi/railties/local_amqp_publisher" if defined?(Rails)
require "acapi/railties/abstract_subscription" if defined?(Rails)
