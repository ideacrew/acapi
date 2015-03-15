require "acapi/version"
require "active_support"

require "acapi/config"
require "acapi/publisher"
require "acapi/subscriber"

module Acapi

  def configure
    block_given? ? yield(Config) : Config
  end

end
