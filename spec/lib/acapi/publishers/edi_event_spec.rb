require 'spec_helper'
require 'acapi/publishers/edi_event'

describe Acapi::Publishers::EdiEvent do
  include Acapi::Publishers::EdiEvent
  context "edi_event" do
    before(:each ) do
      ActiveSupport::Notifications.unsubscribe("acapi.edi_event")
    end

    it "with hash" do 
      ActiveSupport::Notifications.subscribe('acapi.edi_event') do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        expect(event.payload[:body]).to eq "hello"
      end
      edi_event("hello") 
    end

    it "with block" do
      ActiveSupport::Notifications.subscribe('acapi.edi_event') do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        expect(event.payload[:blk].call).to eq "test block"
      end
      edi_event("hello") { "test block" }
    end
  end
end
