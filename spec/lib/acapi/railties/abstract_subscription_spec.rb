require 'spec_helper'

require 'acapi/railties/abstract_subscription'

module DontPolluteMyNamespace
  class SubscriberForExampleSake < Acapi::Subscription
    def self.subscription_details
      ["local.bogusevent.whatever"]
    end

    def call(e_name, e_start, e_end, msg_id, payload)
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
    let(:slug_event_handler) { double }

    before :each do
      allow(DontPolluteMyNamespace::SubscriberForExampleSake).to receive(:new).and_return(slug_event_handler)
      Rails.application.config.acapi.add_subscription(DontPolluteMyNamespace::SubscriberForExampleSake)
    end

    it "should send events to the new subscription" do
      Rails.application.initialize!
      expect(slug_event_handler).to receive(:call) do |e_name, e_start, e_end, msg_id, payload|
        expect(e_name).to eq "local.bogusevent.whatever"
        expect(payload).to eq({ :body => "boguswhatever" })
      end
      ActiveSupport::Notifications.instrument("local.bogusevent.whatever", { :body => "boguswhatever" })
    end
  end
end
