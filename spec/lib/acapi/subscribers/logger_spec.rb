require 'spec_helper'
require 'acapi/subscribers/logger'
require 'acapi/publishers/logger'

describe Acapi::Subscribers::Logger do
  include Acapi::Publishers::Logger
  context "register" do
    it "invoked the Acapi::LocalAmqpPublisher.log" do
      ActiveSupport::Notifications.unsubscribe("acapi.logger")
      expect(Acapi::LocalAmqpPublisher).to receive(:log)

      Acapi::Subscribers::Logger.register("acapi.logger") 
      logger("hello") 
    end
  end
end
