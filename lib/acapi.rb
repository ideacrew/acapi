require "acapi/version"
require "active_support"

require "acapi/config"
require "acapi/publisher"
require "acapi/subscriber"

require "acapi/local_amqp_publisher"
require "acapi/local_amqp_subscriber"

module Acapi

  def configure
    block_given? ? yield(Config) : Config
  end

end

require "acapi/railties/amqp_configuration_options" if defined?(Rails)
require "acapi/railties/local_amqp_publisher" if defined?(Rails)
require "acapi/railties/local_amqp_subscriber" if defined?(Rails)
