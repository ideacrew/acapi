require 'spec_helper'
require 'acapi/subscribers/logger'
require 'acapi/publishers/logger'

describe Acapi::Subscribers::Logger do
  include Acapi::Publishers::Logger
  context "register" do
    before :each do
      ActiveSupport::Notifications.unsubscribe("acapi.logger") 
    end

    it "invoked the Acapi::LocalAmqpPublisher.log" do
      expect(Acapi::LocalAmqpPublisher).to receive(:log)

      Acapi::Subscribers::Logger.register("acapi.logger") 
      logger("hello") 
    end

    it "returns error meta when LocalAmqpPublisher got error" do
      allow(Acapi::LocalAmqpPublisher).to receive(:log).and_raise("error")

      Acapi::Subscribers::Logger.register("acapi.logger") 
      expect{logger("hello")}.to raise_error 
    end
  end
end
