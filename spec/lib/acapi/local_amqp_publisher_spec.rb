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
    it "publishes with a routing key the same as the event name, just stripped of 'acapi.'"
    it "creates the submitted_at key from the finished_at property of the event"
    it "uses the :body property of the event to populate the body of the message"
    it "uses all other event properties as headers"
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
