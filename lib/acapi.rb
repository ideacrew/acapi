require "acapi/version"
require "active_support"

require "acapi/config"
require "acapi/publisher"
require "acapi/subscriber"

require "acapi/local_amqp_publisher"

module Acapi

  def configure
    block_given? ? yield(Config) : Config
  end

end

require "acapi/railties/local_amqp_publisher" if defined?(Rails)
