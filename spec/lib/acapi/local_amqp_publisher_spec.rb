require 'spec_helper'

describe "on application start" do
  it "initializes a pool of connections to the local AMQP broker"
end

describe "when an event is published" do
  it "places that event in a persistent storage queue on the local broker"
end
