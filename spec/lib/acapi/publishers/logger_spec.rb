require 'spec_helper'
require 'acapi/publishers/logger'

describe Acapi::Publishers::Logger do
  include Acapi::Publishers::Logger
  context "logger" do
    before(:each ) do
      ActiveSupport::Notifications.unsubscribe("acapi.logger")
    end

    it "with hash" do 
      ActiveSupport::Notifications.subscribe('acapi.logger') do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        expect(event.payload[:body]).to eq "hello"
      end
      logger("hello") 
    end

    it "with block" do
      ActiveSupport::Notifications.subscribe('acapi.logger') do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        expect(event.payload[:blk].call).to eq "test block"
      end
      logger("hello") { "test block" }
    end
  end
end
