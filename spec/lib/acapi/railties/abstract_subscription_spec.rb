require 'spec_helper'

require 'acapi/railties/abstract_subscription'

module DontPolluteMyNamespace
  class SubscriberForExampleSake < Acapi::Subscription
    def self.subscription_details
      ["local.bogusevent.whatever"]
    end

    def self.set_mock_instance(mi)
      @@mock_instance = mi
    end

    def call(*args)
      @@mock_instance.call(*args)
    end
  end

  class AsyncSubscriberForExampleSake < Acapi::Subscription
    def self.subscription_details
      ["local.async.bogusevent.whatever"]
    end

    def self.set_mock_instance(mi)
      @@mock_instance = mi
    end

    def call(*args)
      @@mock_instance.call(*args)
    end
  end
end

describe "Abstract subscription railtie" do
  describe "with the proper rails configuration options" do
    it "should have a way to add subscriptions" do
      expect(Rails.application.config.acapi).to respond_to(:add_subscription)
    end
  end

  describe "provided a bogus event to experiment on" do
    before :all do
      @slug_event_handler = Object.new
      @slug_async_event_handler = Object.new
      DontPolluteMyNamespace::SubscriberForExampleSake.set_mock_instance(@slug_event_handler)
      DontPolluteMyNamespace::AsyncSubscriberForExampleSake.set_mock_instance(@slug_async_event_handler)
    end

    it "should send synchronous events to the new subscription" do
      Rails.application.config.acapi.add_subscription(DontPolluteMyNamespace::SubscriberForExampleSake)
      Rails.application.config.acapi.register_all_additional_subscriptions
      expect(@slug_event_handler).to receive(:call).at_least(:once) do |e_name, e_start, e_end, msg_id, payload|
        expect(e_name).to eq "local.bogusevent.whatever"
        expect(payload).to eq({ :body => "boguswhatever" })
      end
      ActiveSupport::Notifications.instrument("local.bogusevent.whatever", { :body => "boguswhatever" })
    end

    it "should send asynchronous events to the new subscription" do
      Rails.application.config.acapi.add_async_subscription(DontPolluteMyNamespace::AsyncSubscriberForExampleSake)
      Rails.application.config.acapi.register_async_subscribers!
      expect(@slug_async_event_handler).to receive(:call).at_least(:once) do |e_name, e_start, e_end, msg_id, payload|
        expect(e_name).to eq "local.async.bogusevent.whatever"
        expect(payload).to eq({ :body => "boguswhatever" })
      end
      ActiveSupport::Notifications.instrument("local.async.bogusevent.whatever", { :body => "boguswhatever" })
    end
  end

end
