require 'spec_helper'

describe Acapi::LocalAmqpPublisher do
  let(:forwarding_queue_name) { "acapi.events.local" }

  describe "on initialization" do
    let(:session) { instance_double("Bunny::Session") }
    let(:channel) { instance_double("Bunny::Channel") }
    let(:queue) { instance_double("Bunny::Queue") }

    before :each do
      allow(Bunny).to receive(:new).and_return(session)
      allow(session).to receive(:start)
      allow(session).to receive(:create_channel).and_return(channel)
      allow(channel).to receive(:queue).with(forwarding_queue_name, {:persistent => true}).and_return(queue)
    end

    it "should establish a connection to the local broker" do
      expect(Bunny).to receive(:new).and_return(session)
      expect(session).to receive(:start)
      expect(session).to receive(:create_channel).and_return(channel)
      ::Acapi::LocalAmqpPublisher.boot!
    end

    it "should establish a persistent queue on the local broker" do
      expect(channel).to receive(:queue).with(forwarding_queue_name, {:persistent => true}).and_return(queue)
      ::Acapi::LocalAmqpPublisher.boot!
    end
  end

  describe "which publishes messages" do
    let(:session) { instance_double("Bunny::Session") }
    let(:channel) { instance_double("Bunny::Channel") }
    let(:queue) { instance_double("Bunny::Queue") }
    subject { ::Acapi::LocalAmqpPublisher.new(session, channel, queue) }

    let(:event_name) { "acapi.individual.created" }
    let(:started_at) { double }
    let(:finished_at) { double }
    let(:message_id) { double }
    let(:other_property_1) { double }
    let(:other_property_2) { double }

    let(:payload) { { 
      :other_property_1 => other_property_1,
      :other_property_2 => other_property_2,
    } }

    it "publishes with a routing key the same as the event name, just stripped of 'acapi.'" do
      expect(queue).to receive(:publish) do |body, opts|
        expect(body).to eql ""
        expect(opts[:routing_key]).to eq "individual.created"
      end
      subject.log(event_name, started_at, finished_at, message_id, payload)
    end

    it "creates the submitted_timestamp key from the finished_at property of the event" do
      expect(queue).to receive(:publish) do |body, opts|
        expect(body).to eql ""
        expect(opts[:headers][:submitted_timestamp]).to eq finished_at
      end
      subject.log(event_name, started_at, finished_at, message_id, payload)
    end
    
    it "uses the :body property of the event to populate the body of the message" do
      message_body_content = "a message body"
      message_body = double(:to_s => message_body_content)
      message_with_body = payload.merge(:body => message_body)
      expect(queue).to receive(:publish) do |body, opts|
        expect(body).to eql message_body_content
      end
      subject.log(event_name, started_at, finished_at, message_id, message_with_body)
    end

    it "uses all other event properties as headers" do
      expect(queue).to receive(:publish) do |body, opts|
        expect(body).to eql ""
        expect(opts[:headers][:other_property_1]).to eq other_property_1
        expect(opts[:headers][:other_property_2]).to eq other_property_2
      end
      subject.log(event_name, started_at, finished_at, message_id, payload)
    end
  end

  describe "that can support unicorn" do
    let(:session) { instance_double("Bunny::Session") }
    let(:channel) { instance_double("Bunny::Channel") }
    let(:queue) { instance_double("Bunny::Queue") }
    subject { ::Acapi::LocalAmqpPublisher.new(session, channel, queue) }

    it "supports reconnection for after_fork" do
      expect(session).to receive(:close)
      expect(Bunny).to receive(:new).and_return(session)
      expect(session).to receive(:start)
      expect(session).to receive(:create_channel).and_return(channel)
      expect(channel).to receive(:queue).with(forwarding_queue_name, {:persistent => true}).and_return(queue)
      subject.reconnect!
    end

  end
end
