require 'spec_helper'
require 'acapi/publishers/corp_logger'

describe Acapi::Publishers::CorpLogger do
  include Acapi::Publishers::CorpLogger
  context "corp_logger_notification" do
    it "with hash" do
      expect(corp_logger_notification(msg: "hello")).to eq ActiveSupport::Notifications.instrument('logger', {msg: "hello"})
    end

    it "with block" do
      flag = false
      ActiveSupport::Notifications.subscribe('logger') do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        event.payload[:blk].call
        expect(flag).to eq true
      end
      expect(corp_logger_notification(msg: "hello"){ flag=true }).to eq ActiveSupport::Notifications.instrument('logger', {msg: "hello", blk: -> {flag = true} })
    end
  end
end
