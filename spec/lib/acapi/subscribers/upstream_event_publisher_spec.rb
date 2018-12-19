require 'spec_helper'
require 'acapi/railties/local_amqp_publisher'
require 'acapi/railties/amqp_configuration_options'

describe Acapi::Publishers::UpstreamEventPublisher do

  subject { ::Acapi::Publishers::UpstreamEventPublisher.new }

  let(:forwarding_queue_name) { "acapi.queue.events.local" }
  let(:session) { instance_double("Bunny::Session") }
  let(:channel) { instance_double("Bunny::Channel") }
  let(:queue) { instance_double("Bunny::Queue") }
  let(:exchange) { instance_double("Bunny::Exchange") }
  let(:app_id) { "my app" }
  let(:event_name) { "acapi.individual.created" }
  let(:utf_payload_body) { "sjdbjhs" }
  let(:ascii_payload_body) { ["\xE2"].pack("a1").force_encoding(Encoding::ASCII_8BIT) }
  let(:tprops) { double(:message_id => nil, :to_hash => {}) }
  let(:delivery_info) { double(:delivery_tag => "abcde") }

  before :each do
    allow(Bunny).to receive(:new).and_return(session)
    allow(session).to receive(:start)
    allow(session).to receive(:close)
    allow(session).to receive(:create_channel).and_return(channel)
    allow(channel).to receive(:prefetch).and_return(true)
    allow(channel).to receive(:queue).with(forwarding_queue_name, {:durable => true}).and_return(queue)
    allow(channel).to receive(:acknowledge).with(any_args).and_return(true)
    allow(queue).to receive(:subscribe).with(any_args).and_yield(delivery_info, tprops, payload)
    allow_any_instance_of(Acapi::Amqp::InMessage).to receive(:extract_event_name).and_return(forwarding_queue_name)
    allow(Rails.application.config.acapi).to receive(:remote_broker_uri).and_return('amqp.test_uri')
    allow(Rails.application.config.acapi).to receive_message_chain(:remote_event_queue).and_return(forwarding_queue_name)
    allow(Rails.application).to receive_message_chain(:app_id).and_return(app_id)
  end

  context "for ascii payload" do
    let(:payload) { ascii_payload_body }

    it "should not throw any error for ASCII-8BIT payload" do
      expect{subject.run}.not_to raise_error
    end
  end

  context "for utf payload" do
    let(:payload) { utf_payload_body }

    it "should not throw any error for ASCII-8BIT payload" do
      expect{subject.run}.not_to raise_error
    end
  end

  context 'for JSON dump' do
    let(:message) {
      { :error_message => payload }
    }

    context 'for ASCII-8BIT message' do
      let(:payload) { ascii_payload_body }

      it "should throw error as the encoding type is ASCII-8BIT" do
        expect{JSON.dump(message)}.to raise_error(Encoding::UndefinedConversionError)
      end
    end

    context 'for UTF-8 message' do
      let(:payload) { utf_payload_body }

      it "should not throw error as the encoding type is UTF-8" do
        expect{JSON.dump(message)}.not_to raise_error
      end
    end
  end
end