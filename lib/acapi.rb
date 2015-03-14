require "active_support"

require "acapi/version"
require "acapi/publishers"
require "acapi/subscribers"


module Acapi

  def configure
    block_given? ? yield(Config) : Config
  end

end
