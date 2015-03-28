require 'spec_helper'
require 'acapi/subscribers/corp_logger'
require 'acapi/publishers/corp_logger'

describe Acapi::Subscribers::CorpLogger do
  include Acapi::Publishers::CorpLogger
  context "register" do
    it "triggered the event" do
      family = "a"
      Acapi::Subscribers::CorpLogger.register("logger")

      corp_logger_notification(msg: "hello") { family = "b"; event }
      expect(event).to eq "b"
    end
  end
end
