require 'spec_helper'
require 'acapi/subscribers/edi'
require 'acapi/railties/abstract_subscription'

describe Acapi::Subscribers::Edi do
  describe "provided a edi event to enrollment" do
    let(:slug_event_handler) { double }

    before :each do
      allow(Acapi::Subscribers::Edi).to receive(:new).and_return(slug_event_handler)
      Rails.application.config.acapi.add_subscription(Acapi::Subscribers::Edi)
    end

    it "should send events to the new subscription" do
      Rails.application.instance_eval { @initialized = false }
      Rails.application.initialize!
      Rails.application.config.acapi.register_all_additional_subscriptions

      expect(slug_event_handler).to receive(:call) do |e_name, e_start, e_end, msg_id, payload|
        expect(e_name).to eq "acapi.info.events.enrollment.submitted"
        expect(payload).to eq({ :body => "enrollment" })
      end
      ActiveSupport::Notifications.instrument("acapi.info.events.enrollment.submitted", { :body => "enrollment" })
    end
  end
end
