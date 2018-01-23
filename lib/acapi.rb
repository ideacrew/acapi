require "acapi/version"
require "active_support"

require "acapi/config"
require "acapi/notifiers"
require "acapi/publisher"
require "acapi/subscriber"

require "acapi/subscribers/acapi_events"

require "acapi/amqp/in_message"
require "acapi/amqp/out_message"
require "acapi/amqp/requestor"
require "acapi/amqp/responder"
require "acapi/amqp/client"
require "acapi/requestor"
require "acapi/local_amqp_publisher"

require "acapi/sneakers_extensions"
require "acapi/amqp/worker_specification"
require "acapi/amqp_event_worker"

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
require "acapi/railties/amqp_worker_options" if defined?(Rails)
