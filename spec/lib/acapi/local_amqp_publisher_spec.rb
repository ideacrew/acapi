require 'spec_helper'

describe "on initialization" do
  let(:session) { instance_double("Bunny::Session") }
  let(:channel) { instance_double("Bunny::Channel") }
  let(:queue) { instance_double("Bunny::Queue") }
  let(:forwarding_queue_name) { "acapi.events.local" }

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
